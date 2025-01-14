#ifndef ASTNODE_H
#define ASTNODE_H

#include <iostream>
using namespace std;

struct Node {
    Node* left;
    Node* right;
    string content; // 2-numar + -operator
    string type;
};

class ASTNode{

    Node *root;

    public:
    ASTNode();
    void AddNode(string content,Node*left,Node*right,string type);
    void printTree();
    string evaluateTree();
    ~ASTNode();
};

#endif // ASTNODE_H
