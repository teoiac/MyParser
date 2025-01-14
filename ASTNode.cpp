#include "ASTNode.h"

ASTNode::ASTNode(Type t, const std::string& val) : type(t), value(val), left(nullptr), right(nullptr) {}

ASTNode::ASTNode(Type t, const std::string& val, ASTNode* l, ASTNode* r)
    : type(t), value(val), left(l), right(r) {}

ASTNode::~ASTNode() {
    delete left;
    delete right;
}

std::string ASTNode::evaluate() {
    if(this==nullptr)
    {
        throw std::runtime_error("Null ASTNode during evaluation");
    }
    if (type == INT || type == FLOAT || type == BOOLEAN || type == STRING) {
        return value;  // Leaf node: return value
    } else if (type == OPERATOR) {
        if (!left || !right) {
            throw std::runtime_error("Invalid AST structure for operator: " + value);
        }

        double leftVal = std::stod(left->evaluate());
        double rightVal = std::stod(right->evaluate());

        if (value == "+") return std::to_string(leftVal + rightVal);
        if (value == "-") return std::to_string(leftVal - rightVal);
        if (value == "*") return std::to_string(leftVal * rightVal);
        if (value == "/") {
            if (rightVal == 0) throw std::runtime_error("Division by zero");
            return std::to_string(leftVal / rightVal);
        }
    }
    throw std::runtime_error("Unsupported operation in AST evaluation");
}
