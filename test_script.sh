#!/bin/bash

FAKE_USER_DIR="/home/nonexistent_test_user_12345"

echo "Attempting to delete directory: $FAKE_USER_DIR"

if [ -d "$FAKE_USER_DIR" ]; then
    rm -rf "$FAKE_USER_DIR"
    echo "Directory deleted"
else
    echo "Directory does not exist - nothing to delete"
fi
