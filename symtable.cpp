#include "SymTable.h"

SymTable::SymTable(const std::string& name, SymTable* parent)
    : name(name), parent(parent) {}

void SymTable::addVar(const std::string& type, const std::string& name, const std::string& value) {
    vars.push_back({type, name, value});
}

void SymTable::addFunction(const FunctionInfo& funcInfo) {
    functions.push_back(funcInfo);
}

void SymTable::addClass(std::string name) {
    classes.push_back(name);
}

bool SymTable::existsVar(const std::string& name) const {
    for (const auto& var : vars) {
        if (var.name == name) return true;
    }
    return parent ? parent->existsVar(name) : false;
}

std::string SymTable::getVarType(const std::string& name) const {
    for (const auto& var : vars) {
        if (var.name == name) return var.type;
    }
    return parent ? parent->getVarType(name) : "undefined";
}

std::string SymTable::getVarValue(const std::string& name) const {
    for (const auto& var : vars) {
        if (var.name == name) return var.value;
    }
    return parent ? parent->getVarValue(name) : "undefined";
}

void SymTable::printTableToFile(const char* filename) const {
    // Open the file for writing
    std::ofstream outputFile(filename);

    // Check if the file is opened successfully
    if (!outputFile.is_open()) {
        std::cerr << "Error: Unable to open file " << filename << " for writing.\n";
        return;
    }

    // Indentation to format the symbol table nicely
    std::string indentation(indent, ' ');

    // Print scope name
    outputFile << indentation << "miau" <<"\n";
    outputFile << indentation << "Scope: " << name << "\n";

    // Print variables
    outputFile << indentation << "Variables:\n";
    for (const auto& var : vars) {
        outputFile << indentation << "  - " << var.name << " (Type: " << var.type << ", Value: " << var.value << ")\n";
    }

    // Print functions
    outputFile << indentation << "Functions:\n";
    for (const auto& func : functions) {
        outputFile << indentation << "  - " << func.name << " (Return Type: " << func.returnType << ")\n";
    }

    // Print classes
    outputFile << indentation << "Classes:\n";
    for (const auto& className : classes) {
        outputFile << indentation << "  - " << className << "\n";
    }

    // Print parent scope (if any)
    if (parent) {
        outputFile << indentation << "Parent Scope: " << parent->name << "\n";
    }

    // Close the file after writing
    outputFile.close();
}

SymTable::~SymTable() {}
