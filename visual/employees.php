<?php
require_once 'classess/Database.php';

$conn = Database::getInstance()->getConnection();

// Obsługa sortowania
$sort_col = $_GET['sort'] ?? 'nazwisko';
$sort_order = $_GET['order'] ?? 'ASC';
$next_order = ($sort_order === 'ASC') ? 'DESC' : 'ASC';

// Dozwolone kolumny do sortowania
$allowed_cols = ['imie', 'nazwisko', 'stanowisko', 'nazwa_jednostki', 'email_sluzbowy'];
if (!in_array($sort_col, $allowed_cols)) {
    $sort_col = 'nazwisko';
}

// Obsługa wyszukiwania
$search = $_GET['search'] ?? '';
$where_clause = "";
$params = [];

if (!empty($search)) {
    // Proste wyszukiwanie (ILIKE) - nieczułe na wielkość liter
    $where_clause = "WHERE p.imie ILIKE :search OR p.nazwisko ILIKE :search OR p.stanowisko ILIKE :search OR j.nazwa_jednostki ILIKE :search";
    $params[':search'] = '%' . $search . '%';
}

try {
    $query = "
        SELECT 
            p.imie, 
            p.nazwisko, 
            p.email_sluzbowy, 
            p.stanowisko, 
            j.nazwa_jednostki 
        FROM pracownicy p
        LEFT JOIN jednostki_organizacyjne j ON p.jednostka_id = j.jednostka_id
        $where_clause
        ORDER BY {$sort_col} {$sort_order}
    ";
    $stmt = $conn->prepare($query);
    $stmt->execute($params);
    $pracownicy = $stmt->fetchAll();
} catch (PDOException $e) {
    die("Błąd zapytania: " . $e->getMessage());
}

include 'header.php';
?>



    <div class="page-header">
        <h1 class="page-title">Lista Pracowników</h1>
        <a href="index.php" class="btn">Powrót do Menu</a>
    </div>

    <!-- Pasek wyszukiwania -->
    <div class="search-bar">
        <form method="GET" action="employees.php" class="input-group">
            <label for="search" style="font-weight: bold;">Szukaj:</label>
            <input type="text" name="search" id="search" class="form-control" placeholder="Imię, Nazwisko lub Stanowisko..." value="<?= htmlspecialchars($search) ?>">
            <button type="submit" class="btn btn-primary">Szukaj</button>
            <?php if (!empty($search)): ?>
                <a href="employees.php" class="btn" style="background-color: var(--danger-color); border: none; color: white;">Wyczyść</a>
            <?php endif; ?>
            <!-- Zachowanie sortowania przy wyszukiwaniu -->
            <input type="hidden" name="sort" value="<?= htmlspecialchars($sort_col) ?>">
            <input type="hidden" name="order" value="<?= htmlspecialchars($sort_order) ?>">
        </form>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th><a href="?sort=imie&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Imię <?= $sort_col == 'imie' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th><a href="?sort=nazwisko&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Nazwisko <?= $sort_col == 'nazwisko' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th><a href="?sort=stanowisko&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Stanowisko <?= $sort_col == 'stanowisko' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th><a href="?sort=nazwa_jednostki&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Dział <?= $sort_col == 'nazwa_jednostki' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th><a href="?sort=email_sluzbowy&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Email <?= $sort_col == 'email_sluzbowy' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($pracownicy)): ?>
                    <tr><td colspan="5" style="text-align: center;">Brak wyników dla zapytania: <code><?= htmlspecialchars($search) ?></code></td></tr>
                <?php else: ?>
                    <?php foreach ($pracownicy as $pracownik): ?>
                        <tr>
                            <td><?= htmlspecialchars($pracownik['imie']) ?></td>
                            <td><?= htmlspecialchars($pracownik['nazwisko']) ?></td>
                            <td><?= htmlspecialchars($pracownik['stanowisko']) ?></td>
                            <td><span class="badge badge-info"><?= htmlspecialchars($pracownik['nazwa_jednostki'] ?? 'Brak') ?></span></td>
                            <td><?= htmlspecialchars($pracownik['email_sluzbowy'] ?? '-') ?></td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

</div> <!-- Zamknięcie container z header.php -->

</body>
</html>