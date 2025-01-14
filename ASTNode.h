#ifndef ASTNODE_H
#define ASTNODE_H

#include <iostream>
#include <string>
#include <stdexcept>
#include "SymTable.h"

class ASTNode {
public:
    enum Type { INT, FLOAT, BOOLEAN, STRING, OPERATOR, IDENTIFIER };

    Type type;
    std::string value;  // Operator, identifier name, or literal value
    ASTNode* left;      // Left child
    ASTNode* right;     // Right child

    ASTNode(Type t, const std::string& val);
    ASTNode(Type t, const std::string& val, ASTNode* l, ASTNode* r);
    ~ASTNode();

    std::string evaluate();
};

#endif
