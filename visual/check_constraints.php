<?php
require_once 'classess/Database.php';

try {
    $conn = Database::getInstance()->getConnection();
    
    echo "<h1>Check Constraints</h1>";
    
    $tables = ['wynagrodzenia', 'zlecenia_produkcyjne'];
    
    foreach ($tables as $table) {
        echo "<h2>Table: $table</h2>";
        $stmt = $conn->prepare("
            SELECT conname, pg_get_constraintdef(oid) as definition
            FROM pg_constraint
            WHERE conrelid = :table::regclass
            AND contype = 'c'
        ");
        $stmt->execute([':table' => $table]);
        $constraints = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (empty($constraints)) {
            echo "No check constraints found.<br>";
        } else {
            echo "<ul>";
            foreach ($constraints as $c) {
                echo "<li><b>{$c['conname']}</b>: {$c['definition']}</li>";
            }
            echo "</ul>";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
