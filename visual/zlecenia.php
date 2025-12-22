<?php
require_once 'classess/Database.php';

$conn = Database::getInstance()->getConnection();

// Obsługa sortowania
$sort_col = $_GET['sort'] ?? 'data_przyjecia_zlecenia';
$sort_order = $_GET['order'] ?? 'DESC';
$next_order = ($sort_order === 'ASC') ? 'DESC' : 'ASC';

// Dozwolone kolumny
$allowed_cols = ['numer_zlecenia_klienta', 'nazwa_klienta', 'nazwa_produktu', 'ilosc', 'cena_jednostkowa', 'data_przyjecia_zlecenia', 'czy_zakonczona'];
if (!in_array($sort_col, $allowed_cols)) {
    $sort_col = 'data_przyjecia_zlecenia';
}

// Obsługa wyszukiwania
$search = $_GET['search'] ?? '';
$where_clause = "";
$params = [];

if (!empty($search)) {
    // Proste wyszukiwanie (ILIKE)
    $where_clause = "WHERE z.numer_zlecenia_klienta ILIKE :search OR k.nazwa_klienta ILIKE :search OR z.nazwa_produktu ILIKE :search";
    $params[':search'] = '%' . $search . '%';
}

try {
    $query = "
        SELECT 
            z.numer_zlecenia_klienta,
            k.nazwa_klienta,
            z.nazwa_produktu,
            z.ilosc,
            z.cena_jednostkowa,
            z.waluta,
            z.data_przyjecia_zlecenia,
            z.przewidywana_data_realizacji,
            z.czy_zakonczona
        FROM zlecenia_produkcyjne z
        LEFT JOIN klienci k ON z.klient_id = k.klient_id
        $where_clause
        ORDER BY {$sort_col} {$sort_order}
    ";
    $stmt = $conn->prepare($query);
    $stmt->execute($params);
    $zlecenia = $stmt->fetchAll();
} catch (PDOException $e) {
    die("Błąd zapytania: " . $e->getMessage());
}

include 'header.php';

?>

<div class="page-header">
    <h1 class="page-title">Zlecenia Produkcyjne</h1>
    <a href="index.php" class="btn">Powrót do Menu</a>
</div>

<!-- Pasek wyszukiwania -->
    <div class="search-bar">
        <form method="GET" action="zlecenia.php" class="input-group">
            <label for="search" style="font-weight: bold;">Szukaj:</label>
            <input type="text" name="search" id="search" class="form-control" placeholder="Nr zlecenia, Klient lub Produkt..." value="<?= htmlspecialchars($search) ?>">
            <button type="submit" class="btn btn-primary">Szukaj</button>
            <?php if (!empty($search)): ?>
                <a href="zlecenia.php" class="btn" style="background-color: var(--danger-color); border: none; color: white;">Wyczyść</a>
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
                    <th><a href="?sort=numer_zlecenia_klienta&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Nr Zlecenia <?= $sort_col == 'numer_zlecenia_klienta' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th><a href="?sort=nazwa_klienta&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Klient <?= $sort_col == 'nazwa_klienta' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th><a href="?sort=nazwa_produktu&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Produkt <?= $sort_col == 'nazwa_produktu' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th style="text-align: right;"><a href="?sort=ilosc&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Ilość <?= $sort_col == 'ilosc' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th style="text-align: right;"><a href="?sort=cena_jednostkowa&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Wartość (ok.) <?= $sort_col == 'cena_jednostkowa' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th><a href="?sort=data_przyjecia_zlecenia&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Data Przyjęcia <?= $sort_col == 'data_przyjecia_zlecenia' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                    <th style="text-align: center;"><a href="?sort=czy_zakonczona&order=<?= $next_order ?>&search=<?= urlencode($search) ?>">Status <?= $sort_col == 'czy_zakonczona' ? ($sort_order == 'ASC' ? '^' : 'v') : '' ?></a></th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($zlecenia)): ?>
                    <tr><td colspan="7" style="text-align: center;">Brak wyników dla zapytania: <code><?= htmlspecialchars($search) ?></code></td></tr>
                <?php else: ?>
                    <?php foreach ($zlecenia as $z): ?>
                        <tr>
                            <td><?= htmlspecialchars($z['numer_zlecenia_klienta']) ?></td>
                            <td><?= htmlspecialchars($z['nazwa_klienta'] ?? 'Nieznany') ?></td>
                            <td><?= htmlspecialchars($z['nazwa_produktu']) ?></td>
                            <td style="text-align: right;"><?= number_format($z['ilosc'], 0, ',', ' ') ?> szt.</td>
                            <td style="text-align: right;"><?= number_format($z['ilosc'] * $z['cena_jednostkowa'], 2, ',', ' ') ?> <?= $z['waluta'] ?></td>
                            <td><?= htmlspecialchars($z['data_przyjecia_zlecenia']) ?></td>
                            <td style="text-align: center;">
                                <?php if ($z['czy_zakonczona'] == 't' || $z['czy_zakonczona'] === true): ?>
                                    <span class="badge badge-success">Zakończone</span>
                                <?php else: ?>
                                    <span class="badge badge-warning">W toku</span>
                                <?php endif; ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

</div> <!-- Zamknięcie container -->

</body>
</html>
