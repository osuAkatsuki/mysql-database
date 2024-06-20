#!/usr/bin/env bash
set -euo pipefail

test_migration_sequentiality() {
    count=1
    for migration_filename in $(ls migrations | sort -nk1); do
        m=$(echo $migration_filename | cut -d'_' -f1)
        echo "Running migration $m"
        if [ $count -ne $m ]; then
            echo "Migration $m is out of order"
            exit 1
        fi
        count=$((count + 1))
    done
    echo "All migrations are in order"
}

test_migration_sequentiality
