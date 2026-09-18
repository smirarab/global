#!/usr/bin/env python3

import argparse
import gzip
import os
import sys

try:
    import treeswift
    from treeswift import Node
except ImportError as exc:
    raise SystemExit(
        "This script requires TreeSwift. Install it with 'pip install treeswift'."
    ) from exc


def read_one_newick(path):
    if path.endswith(".gz"):
        with gzip.open(path, "rt") as handle:
            newick = handle.read()
    elif os.path.exists(path):
        with open(path, "rt") as handle:
            newick = handle.read()
    else:
        newick = path
    tree = treeswift.read_tree_newick(newick)
    if isinstance(tree, list):
        if len(tree) != 1:
            raise ValueError(f"Expected exactly one tree in {path}, found {len(tree)}")
        tree = tree[0]
    return tree


def parse_outgroups(raw):
    if raw is None:
        return []
    outgroups = [label.strip() for label in raw.split(",") if label.strip()]
    if not outgroups:
        raise ValueError("--outgroup was provided but no non-empty labels were found")
    duplicates = sorted({label for label in outgroups if outgroups.count(label) > 1})
    if duplicates:
        raise ValueError("Duplicate outgroup labels: " + ", ".join(duplicates))
    return outgroups


def check_unique_leaf_labels(tree, tree_name):
    counts = {}
    for leaf in tree.traverse_leaves():
        counts[leaf.label] = counts.get(leaf.label, 0) + 1
    duplicates = sorted(label for label, count in counts.items() if count > 1)
    if duplicates:
        raise ValueError(
            f"{tree_name} has duplicate leaf labels, cannot match topology by clade: "
            + ", ".join(duplicates)
        )


def clade_index(tree, tree_name):
    check_unique_leaf_labels(tree, tree_name)
    index = {}

    for node in tree.traverse_postorder():
        if node.is_leaf():
            clade = frozenset([node.label])
        else:
            clade = frozenset().union(*(child._merge_clade for child in node.children))
        node._merge_clade = clade
        index.setdefault(clade, []).append(node)

    return index, tree.root._merge_clade


def child_clade_sets(node):
    return {child._merge_clade for child in node.children}


def find_first_node_for_clade(index, clade):
    nodes = index.get(clade)
    if not nodes:
        return None
    return nodes[0]


def find_leaf_by_label(tree, label):
    matches = [leaf for leaf in tree.traverse_leaves() if leaf.label == label]
    if not matches:
        raise ValueError(f"Outgroup leaf not found in support tree: {label}")
    if len(matches) > 1:
        raise ValueError(f"Outgroup leaf label is duplicated in support tree: {label}")
    return matches[0]


def find_outgroup_mrca(tree, outgroups):
    targets = set(outgroups)
    best = None

    for node in tree.traverse_postorder():
        if node.is_leaf():
            found = {node.label} if node.label in targets else set()
        else:
            found = set().union(*(child._outgroup_hits for child in node.children))
        node._outgroup_hits = found
        if found == targets and best is None:
            best = node

    if best is None:
        raise ValueError("Could not find an MRCA for the requested outgroup labels")

    outgroup_clade = getattr(best, "_merge_clade", None)
    if outgroup_clade is None:
        outgroup_clade = descendant_leaf_labels(best)
    if set(outgroup_clade) != targets:
        extras = sorted(set(outgroup_clade) - targets)
        raise ValueError(
            "Requested outgroups are not monophyletic in the support tree"
            + (": also contains " + ", ".join(extras) if extras else "")
        )

    return best


def descendant_leaf_labels(node):
    if node.is_leaf():
        return frozenset([node.label])
    return frozenset().union(*(descendant_leaf_labels(child) for child in node.children))


def reroot_on_outgroup(tree, outgroups):
    if not outgroups:
        return

    if len(outgroups) == 1:
        target = find_leaf_by_label(tree, outgroups[0])
        if target.edge_length is None:
            target.edge_length = 1.0
        length = target.edge_length / 2
    else:
        # Build clades first so we can verify the requested outgroup is monophyletic.
        clade_index(tree, "support tree")
        target = find_outgroup_mrca(tree, outgroups)
        if target.edge_length is None:
            target.edge_length = 1.0
        length = target.edge_length / 2
    tree.reroot(target, length=length, branch_support=True)
    suppress_unlabeled_unifurcations(tree)
    if len(outgroups) > 1:
        enforce_binary_outgroup_root(tree, set(outgroups))


def enforce_binary_outgroup_root(tree, outgroups):
    clade_index(tree, "support tree")
    outgroup_children = [
        child for child in tree.root.children if set(child._merge_clade).issubset(outgroups)
    ]
    if len(outgroup_children) <= 1:
        return

    grouped = set().union(*(set(child._merge_clade) for child in outgroup_children))
    if grouped != outgroups:
        return

    wrapper = Node()
    wrapper.edge_length = None
    wrapper.parent = tree.root
    wrapper.children = []

    remaining = []
    for child in tree.root.children:
        if child in outgroup_children:
            child.parent = wrapper
            wrapper.children.append(child)
        else:
            remaining.append(child)

    tree.root.children = [wrapper] + remaining


def reroot_length_tree_like_support(support_tree, length_tree):
    support_index, support_root_clade = clade_index(support_tree, "support tree")
    length_index, length_root_clade = clade_index(length_tree, "length tree")

    if support_root_clade != length_root_clade:
        missing_from_length = sorted(support_root_clade - length_root_clade)
        missing_from_support = sorted(length_root_clade - support_root_clade)
        details = []
        if missing_from_length:
            details.append("only in support tree: " + ", ".join(missing_from_length))
        if missing_from_support:
            details.append("only in length tree: " + ", ".join(missing_from_support))
        raise ValueError("Leaf sets differ (" + "; ".join(details) + ")")

    if rooted_topologies_match(support_index, length_index):
        return

    if len(support_tree.root.children) != 2:
        raise ValueError(
            "Cannot auto-reroot length tree to match a support tree whose root "
            f"has {len(support_tree.root.children)} children"
        )

    root_child_clades = [child._merge_clade for child in support_tree.root.children]
    root_child_clades.sort(key=lambda clade: (len(clade), sorted(clade)))

    for clade in root_child_clades:
        for candidate in (clade, support_root_clade - clade):
            target = find_first_node_for_clade(length_index, candidate)
            if target is None or target.is_root():
                continue
            length = None
            if target.is_leaf():
                if target.edge_length is None:
                    target.edge_length = 1.0
                length = target.edge_length / 2
            length_tree.reroot(target, length=length, branch_support=False)
            suppress_unlabeled_unifurcations(length_tree)
            return

    example = ", ".join(sorted(root_child_clades[0]))
    raise ValueError(
        "Could not find the support-tree root split in the unrooted length tree; "
        f"one root-side clade is {{{example}}}"
    )


def rooted_topologies_match(support_index, length_index):
    if set(support_index) != set(length_index):
        return False
    for clade, support_nodes in support_index.items():
        length_nodes = length_index[clade]
        if len(support_nodes) != len(length_nodes):
            return False
        for support_node, length_node in zip(support_nodes, length_nodes):
            if child_clade_sets(support_node) != child_clade_sets(length_node):
                return False
    return True


def merge_edge_lengths(parent_length, child_length):
    if parent_length is None:
        return child_length
    if child_length is None:
        return parent_length
    return parent_length + child_length


def suppress_unlabeled_unifurcations(tree):
    changed = True
    while changed:
        changed = False
        for node in list(tree.traverse_preorder()):
            if len(node.children) != 1 or node.label not in (None, ""):
                continue
            child = node.children[0]
            child.edge_length = merge_edge_lengths(node.edge_length, child.edge_length)
            if node.is_root():
                tree.root = child
                child.parent = None
            else:
                parent = node.parent
                parent.children[parent.children.index(node)] = child
                child.parent = parent
            changed = True
            break


def copy_lengths_and_check_topology(support_tree, length_tree):
    support_index, support_root_clade = clade_index(support_tree, "support tree")
    length_index, length_root_clade = clade_index(length_tree, "length tree")

    if support_root_clade != length_root_clade:
        missing_from_length = sorted(support_root_clade - length_root_clade)
        missing_from_support = sorted(length_root_clade - support_root_clade)
        details = []
        if missing_from_length:
            details.append("only in support tree: " + ", ".join(missing_from_length))
        if missing_from_support:
            details.append("only in length tree: " + ", ".join(missing_from_support))
        raise ValueError("Leaf sets differ (" + "; ".join(details) + ")")

    support_clades = set(support_index)
    length_clades = set(length_index)
    if support_clades != length_clades:
        missing_clades = sorted(
            support_clades - length_clades,
            key=lambda clade: (len(clade), sorted(clade)),
        )
        extra_clades = sorted(
            length_clades - support_clades,
            key=lambda clade: (len(clade), sorted(clade)),
        )
        if missing_clades:
            example = ", ".join(sorted(missing_clades[0]))
            raise ValueError(f"Topologies differ; support-tree clade not found in length tree: {{{example}}}")
        example = ", ".join(sorted(extra_clades[0]))
        raise ValueError(f"Topologies differ; length-tree clade not found in support tree: {{{example}}}")

    for clade, support_nodes in support_index.items():
        length_nodes = length_index[clade]
        if len(support_nodes) != len(length_nodes):
            labels = ", ".join(sorted(clade))
            raise ValueError(
                f"Rooted topology differs at clade {{{labels}}}: support tree has "
                f"{len(support_nodes)} matching nodes, length tree has {len(length_nodes)}"
            )
        for support_node, length_node in zip(support_nodes, length_nodes):
            if child_clade_sets(support_node) != child_clade_sets(length_node):
                labels = ", ".join(sorted(clade))
                raise ValueError(f"Rooted topology differs at clade {{{labels}}}")
            support_node.edge_length = length_node.edge_length


def split_key(clade, total_clade):
    other = total_clade - clade
    clade_key = tuple(sorted(clade))
    other_key = tuple(sorted(other))
    if len(clade_key) < len(other_key):
        return clade_key
    if len(other_key) < len(clade_key):
        return other_key
    return min(clade_key, other_key)


def format_clade_for_error(key, max_labels=8):
    labels = list(key)
    if len(labels) <= max_labels:
        return "{" + ", ".join(labels) + "}"
    shown = ", ".join(labels[:max_labels])
    return "{" + shown + f", ... +{len(labels) - max_labels} more" + "}"


def unrooted_split_lengths(tree, total_clade, tree_name):
    split_lengths = {}
    for node in tree.traverse_preorder():
        if node.is_root():
            continue
        key = split_key(node._merge_clade, total_clade)
        if node.edge_length is None:
            raise ValueError(f"{tree_name} is missing a branch length for split {format_clade_for_error(key)}")
        split_lengths[key] = split_lengths.get(key, 0.0) + node.edge_length
    return split_lengths


def copy_lengths_from_unrooted_and_check_topology(support_tree, length_tree, rooted_error=None):
    _, support_root_clade = clade_index(support_tree, "support tree")
    _, length_root_clade = clade_index(length_tree, "length tree")
    if support_root_clade != length_root_clade:
        missing_from_length = sorted(support_root_clade - length_root_clade)
        missing_from_support = sorted(length_root_clade - support_root_clade)
        details = []
        if missing_from_length:
            details.append("only in support tree: " + ", ".join(missing_from_length))
        if missing_from_support:
            details.append("only in length tree: " + ", ".join(missing_from_support))
        raise ValueError("Leaf sets differ (" + "; ".join(details) + ")")

    support_keys = {}
    for node in support_tree.traverse_preorder():
        if node.is_root():
            continue
        key = split_key(node._merge_clade, support_root_clade)
        support_keys.setdefault(key, []).append(node)

    length_splits = unrooted_split_lengths(length_tree, length_root_clade, "length tree")

    missing = sorted(set(support_keys) - set(length_splits), key=lambda key: (len(key), key))
    extra = sorted(set(length_splits) - set(support_keys), key=lambda key: (len(key), key))
    if missing or extra:
        if rooted_error is not None:
            detail = f" Rooted matching also failed: {rooted_error}"
        else:
            detail = ""
        if missing:
            raise ValueError(
                "Unrooted topologies differ; support-tree split not found in length tree: "
                + format_clade_for_error(missing[0])
                + detail
            )
        raise ValueError(
            "Unrooted topologies differ; length-tree split not found in support tree: "
            + format_clade_for_error(extra[0])
            + detail
        )

    for key, nodes in support_keys.items():
        total_length = length_splits[key]
        if len(nodes) == 1:
            nodes[0].edge_length = total_length
            continue

        if (
            len(nodes) == 2
            and all(node.parent is support_tree.root for node in nodes)
        ):
            current_lengths = [node.edge_length for node in nodes]
            if all(length is not None for length in current_lengths) and sum(current_lengths) > 0:
                current_total = sum(current_lengths)
                for node, current_length in zip(nodes, current_lengths):
                    node.edge_length = total_length * current_length / current_total
            else:
                for node in nodes:
                    node.edge_length = total_length / 2
            continue

        raise ValueError(
            "Support tree has duplicate rooted edges for one unrooted split; cannot "
            "assign one unrooted branch length unambiguously: "
            + format_clade_for_error(key)
        )


def write_tree(tree, out_path, hide_rooted_prefix=False):
    if out_path:
        tree.write_tree_newick(out_path, hide_rooted_prefix=hide_rooted_prefix)
        return

    output = tree.newick()
    if hide_rooted_prefix and output.startswith("[&R]"):
        output = output[4:].strip()
    sys.stdout.write(output)
    if not output.endswith("\n"):
        sys.stdout.write("\n")


def build_arg_parser():
    parser = argparse.ArgumentParser(
        description=(
            "Combine two rooted Newick trees with identical topology: keep rooting and "
            "labels/supports from the first tree, and copy branch lengths from the second."
        )
    )
    parser.add_argument("support_tree", help="Newick tree providing topology and internal node labels")
    parser.add_argument("length_tree", help="Newick tree providing branch lengths")
    parser.add_argument(
        "-o",
        "--out",
        help="Output Newick path. Defaults to stdout.",
    )
    parser.add_argument(
        "--outgroup",
        help=(
            "Optional support-tree outgroup leaf label, or comma-separated labels. "
            "Multiple labels must form a monophyletic clade and are rooted on "
            "the edge above their MRCA; rerooting uses TreeSwift "
            "reroot(..., branch_support=True)."
        ),
    )
    parser.add_argument(
        "--hide-rooted-prefix",
        action="store_true",
        help="Hide TreeSwift's '[&R]' prefix in the output Newick.",
    )
    return parser


def main(argv=None):
    args = build_arg_parser().parse_args(argv)
    support_tree = read_one_newick(args.support_tree)
    length_tree = read_one_newick(args.length_tree)

    reroot_on_outgroup(support_tree, parse_outgroups(args.outgroup))
    try:
        reroot_length_tree_like_support(support_tree, length_tree)
        copy_lengths_and_check_topology(support_tree, length_tree)
    except ValueError as rooted_error:
        copy_lengths_from_unrooted_and_check_topology(
            support_tree,
            length_tree,
            rooted_error=rooted_error,
        )
    write_tree(support_tree, args.out, hide_rooted_prefix=args.hide_rooted_prefix)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        raise SystemExit(f"ERROR: {exc}") from exc
