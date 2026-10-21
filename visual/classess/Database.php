<?php 

class Database {

    private static $instance = null;

    private $pdo;

    private $host = 'localhost';
    private $db_name = 'company';
    private $username = '';
    private $password = '';

    private function __construct(){
        $this->host = getenv('DB_HOST') ?: 'localhost';
        $this->db_name = getenv('DB_NAME') ?: 'company_portfolio';
        $this->username = getenv('DB_USER') ?: 'postgres';
        $this->password = getenv('DB_PASSWORD') ?: '';
        try {
            $dsn = "pgsql:host=" . $this->host . ";dbname=" . $this->db_name;

            $this->pdo = new PDO($dsn, $this->username, $this->password);

            $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            $this->pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch (Exception $e) {
            die("Błąd połączenia z baza: " . $e->getMessage());
        }
    }

    public static function getInstance(){
        if (self::$instance == null){
            self::$instance = new Database();
        }
        return self::$instance;
    }

    public function getConnection(){
        return $this->pdo;
    }

    private function __clone(){}
}

?>