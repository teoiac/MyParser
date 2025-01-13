#include "SymTable.h"

SymTable::SymTable(const std::string& name, SymTable* parent, const std::string& scope)
    : name(name), parent(parent), scope(scope){}

void SymTable::addVar(const std::string& type, const std::string& name, const std::string& value) {
    vars.push_back({type, name, value});
}

void SymTable::addValue(string name, string value)
{
    for(auto& var : vars)
    {
        if(var.name==name)
        {
            var.value=value;
        }
    }
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

void SymTable::printTableToFile(const char* filename, bool append) const {
    std::ofstream outputFile;
    if (append) {
        outputFile.open(filename, std::ios::app);
    } else {
        outputFile.open(filename, std::ios::out);
    }

    if (!outputFile.is_open()) {
        std::cerr << "Error: Unable to open file " << filename << " for writing.\n";
        return;
    }

    // Print only the global scope once
    
        outputFile << "Scope and name: " << scope << " " << name << "\n";
        
        // Print variables
        outputFile << "Variables:\n";
        for (const auto& var : vars) {
            outputFile << "  - " << var.name << " (Type: " << var.type 
                    << ", Value: " << (var.value.empty() ? "N/A" : var.value) << ")\n";
        }

        // Print functions
        outputFile << "Functions:\n";
        for (const auto& func : functions) {
            outputFile << "  - " << func.name << " (Return Type: " << func.returnType 
                    << ", Parameters: ";
            for (const auto& param : func.parameters) {
                outputFile << param.type << " " << param.name << ", ";
            }
            outputFile << ")\n";
        }

        // Print classes
        outputFile << "Classes:\n";
        for (const auto& cls : classes) {
            outputFile << "  - " << cls << "\n";
        }
        if(scope!="global")
        outputFile << "Parent scope:"<<parent->name<<"\n";
    

    // Print nested scopes (for parent scopes, if any)
    /*if (parent) {
        parent->printTableToFile(filename, true);  // Pass false for non-global scopes
    }
*/
    outputFile << "\n";
    outputFile.close();
}

SymTable::~SymTable() {}
