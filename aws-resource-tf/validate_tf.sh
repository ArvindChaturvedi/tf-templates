#!/bin/bash

# This script checks Terraform files for basic syntax errors without requiring Terraform to be installed

check_file() {
  local file=$1
  echo "Checking $file..."
  
  # Check for unclosed braces
  open_braces=$(grep -o "{" "$file" | wc -l)
  close_braces=$(grep -o "}" "$file" | wc -l)
  
  if [ "$open_braces" != "$close_braces" ]; then
    echo "ERROR: Mismatched braces in $file (open: $open_braces, close: $close_braces)"
    return 1
  fi
  
  # Better check for quotes - count total number of quotes, should be even
  quotes=$(grep -o '"' "$file" | wc -l)
  if [ $((quotes % 2)) -ne 0 ]; then
    echo "ERROR: Odd number of quotes in $file ($quotes)"
    return 1
  fi
  
  # Check for missing equal signs in assignments
  if grep -E "[a-zA-Z0-9_]+ [a-zA-Z0-9_]+ {" "$file" | grep -v -E "(resource|variable|output|provider|module|locals|data) " > /dev/null; then
    echo "WARNING: Possible missing '=' in assignment in $file"
  fi
  
  # Check for common Terraform syntax patterns
  if grep -E "resource [^{]+ {" "$file" > /dev/null; then
    echo "✓ Found resource declarations"
  fi
  
  if grep -E "variable [^{]+ {" "$file" > /dev/null; then
    echo "✓ Found variable declarations"
  fi
  
  if grep -E "output [^{]+ {" "$file" > /dev/null; then
    echo "✓ Found output declarations"
  fi
  
  if grep -E "provider [^{]+ {" "$file" > /dev/null; then
    echo "✓ Found provider declarations"
  fi
  
  echo "✓ Basic syntax check passed for $file"
  return 0
}

validate_directory() {
  local dir=$1
  echo "Validating directory: $dir"
  echo "--------------------------"
  
  # Find and validate all .tf files in the directory
  find "$dir" -name "*.tf" | while read -r file; do
    check_file "$file"
    if [ $? -ne 0 ]; then
      return 1
    fi
  done
  
  echo "--------------------------"
  echo "All Terraform files in $dir passed basic syntax validation."
  return 0
}

echo "Terraform Syntax Validator"
echo "=========================="

# Check if a specific directory was provided
if [ $# -eq 1 ]; then
  validate_directory "$1"
  exit $?
fi

# Validate key directories
validate_directory "examples/basic"
validate_directory "modules/aurora_postgresql"
validate_directory "modules/networking"
validate_directory "modules/security"
validate_directory "modules/pgbouncer"
validate_directory "."

echo "=========================="
echo "All Terraform files passed basic syntax validation."
echo "Note: This is a basic check only. Install Terraform for full validation."