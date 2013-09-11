/**
 * TreeNode.java
 * For representing trees, as parsed from Newick format files
 * Contains various info for parts of tree, e.g. node lengths (strange
 * newick format), node names, etc.
 * Make it more general later, but for now it only deals with structure
 * of tree with all of newick associated info
 */

import java.io.*;
import java.util.*;

public class TreeNode 
{
    // use Vector
    private List<TreeNode> children;

    // maybe encapsulate this into own class later?
    private String name;
    // newick weird - does lengths per node, not edge
    // really represents this<->parent edge's length
    private double length;
    // just a reference to sequence data - taken from associated alignment
    private String sequence;

    public TreeNode () {
	children = new Vector<TreeNode>();

	setName("");
	setLength(0.0);
    }

    public List<TreeNode> getChildren () {
	return (children);
    }

    public void addChild (TreeNode child) {
	if (child != null) {
	    children.add(child);
	}
    }

    public String getName () {
	return (name);
    }

    public void setName (String name) {
	this.name = name;
    }

    public double getLength () {
	return (length);
    }

    public void setLength (double length) {
	this.length = length;
    }

    public void setSequence (String sequence) {
	this.sequence = sequence;
    }

    public String getSequence () {
	return (sequence);
    }
}


