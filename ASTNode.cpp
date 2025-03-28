#include "ASTNode.h"
#include <math.h>

ASTNode::ASTNode() : root(nullptr)
{}

void ASTNode::AddNode(string content, Node *left, Node *right, string type)
{
    Node *newNode = new Node{left, right, content, type};
    root = newNode;
}

void printInOrder(Node *node)
{
    if (node != nullptr)
    {
        printInOrder(node->left);
        cout << node->content << " ";
        printInOrder(node->right);
    }
}

void ASTNode::printTree()
{
    printInOrder(root);
    cout << endl;
}

int evaluateNodeint(Node *node)
{
    if (node == nullptr)
    {
        return 0;
    }

    if (node->content == "+")
    {
        return evaluateNodeint(node->left) + evaluateNodeint(node->right);
    }
    else if (node->content == "-")
    {
        return evaluateNodeint(node->left) - evaluateNodeint(node->right);
    }
    else if (node->content == "*")
    {
        return evaluateNodeint(node->left) * evaluateNodeint(node->right);
    }
    else if (node->content == "/")
    {
        return evaluateNodeint(node->left) / evaluateNodeint(node->right);
    }
    else if (node->content == "^")
    {
        return pow(evaluateNodeint(node->left), evaluateNodeint(node->right));
    }
    else if(node->type=="int")
    {
        return stoi(node->content);
    }
    else return 0;
}
float evaluateNodefloat(Node *node)
{
    if (node == nullptr)
    {
        return 0;
    }

    if (node->content == "+")
    {
        return evaluateNodefloat(node->left) + evaluateNodefloat(node->right);
    }
    else if (node->content == "-")
    {
        return evaluateNodefloat(node->left) - evaluateNodefloat(node->right);
    }
    else if (node->content == "*")
    {
        return evaluateNodefloat(node->left) * evaluateNodefloat(node->right);
    }
    else if (node->content == "/")
    {
        return evaluateNodefloat(node->left) / evaluateNodefloat(node->right);
    }
    else if (node->content == "^")
    {
        return pow(evaluateNodefloat(node->left), evaluateNodefloat(node->right));
    }
    else if(node->type=="float")
    {
        return stof(node->content);
    }
    return 0;
}
bool evaluateNodebool(Node *node)
{

    if (node->content == "&&")
    {
        return evaluateNodebool(node->left) && evaluateNodebool(node->right);
    }
    else if (node->content == "||")
    {
        return evaluateNodebool(node->left) || evaluateNodebool(node->right);
    }
    else if (node->content == "!")
    {
        return !evaluateNodebool(node->left);
    }
    else if (node->content == "<")
    {
        if (node->left->type == "int")
        {
            return evaluateNodeint(node->left) < evaluateNodeint(node->right);
        }
        else if (node->left->type == "float")
        {
            return evaluateNodefloat(node->left) < evaluateNodefloat(node->right);
        }
    }
    else if (node->content == ">")
    {
        if (node->left->type == "int")
        {
            return evaluateNodeint(node->left) > evaluateNodeint(node->right);
        }
        else if (node->left->type == "float")
        {
            return evaluateNodefloat(node->left) > evaluateNodefloat(node->right);
        }
    }
    else if (node->content == "<=")
    {
        if (node->left->type == "int")
        {
            return evaluateNodeint(node->left) <= evaluateNodeint(node->right);
        }
        else if (node->left->type == "float")
        {
            return evaluateNodefloat(node->left) <= evaluateNodefloat(node->right);
        }
    }
    else if (node->content == ">=")
    {
        if (node->left->type == "int")
        {
            return evaluateNodeint(node->left) >= evaluateNodeint(node->right);
        }
        else if (node->left->type == "float")
        {
            return evaluateNodefloat(node->left) >= evaluateNodefloat(node->right);
        }
    }
    else if (node->content == "==")
    {
        if (node->left->type == "int")
        {
            return evaluateNodeint(node->left) == evaluateNodeint(node->right);
        }
        else if (node->left->type == "float")
        {
            return evaluateNodefloat(node->left) == evaluateNodefloat(node->right);
        }
    }
    else if (node->content == "!=")
    {
        if (node->left->type == "int")
        {
            return evaluateNodeint(node->left) != evaluateNodeint(node->right);
        }
        else if (node->left->type == "float")
        {
            return evaluateNodefloat(node->left) != evaluateNodefloat(node->right);
        }
    }
    else if (node->type=="bool")
    {
        return node->content == "true" ? true : false;
    }
     return 0;
}

string ASTNode::evaluateTree()
{
    if (root == NULL)
    {
        return 0; 
    }
    if (root->content == "+" || root->content == "-" || root->content == "*" || root->content == "/" || root->content == "^")
    {
        if (root->left->type == "int" && root->left->type == "int")
            return to_string(evaluateNodeint(root));
        else if (root->left->type == "float" && root->left->type == "float")
            return to_string(evaluateNodefloat(root));
    }
    else if (root->content == "&&" || root->content == "||" || root->content == "!" || root->content == "<"|| root->content == "<="
    || root->content == ">"|| root->content == ">="||root->content == "=="||root->content == "!=")
    {
        return evaluateNodebool(root) ? "true" : "false";
    }
    else if(root->type=="int"){return to_string(evaluateNodeint(root));}
    else if(root->type=="float"){return to_string(evaluateNodefloat(root));}
    else if(root->type=="bool"){return evaluateNodebool(root)?"true":"false";}
    return 0;
}

ASTNode::~ASTNode()
{
    deleteTree(root); 
}

void ASTNode::deleteTree(Node* node)
{
    if (node == nullptr)
        return;

    
    deleteTree(node->left);
    deleteTree(node->right);

    delete node;
}

