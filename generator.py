import random
from faker import Faker
from datetime import date, timedelta

# Ustawiamy polskie dane
fake = Faker('pl_PL')
Faker.seed(123) # Żeby wyniki były powtarzalne

# Plik wynikowy
output_file = "massive_data.sql"

print("Generowanie danych... To może chwilę potrwać.")

with open(output_file, "w", encoding="utf-8") as f:
    f.write("-- MASOWE DANE DO BAZY COMPANY\n")
    f.write("BEGIN;\n\n")

    # 1. JEDNOSTKI (Dodajemy kilka dodatkowych do istniejących)
    jednostki = ['Dział IT', 'Dział HR', 'Kontrola Jakości', 'Dział Handlowy', 'Utrzymanie Ruchu']
    f.write("-- Generowanie Jednostek\n")
    for i, nazwa in enumerate(jednostki, start=4): # Start od 4, bo 1-3 już są
        sql = f"INSERT INTO jednostki_organizacyjne (jednostka_id, nazwa_jednostki, typ_jednostki, adres) VALUES ({i}, '{nazwa}', 'Dział', '{fake.address().replace('\n', ', ')}') ON CONFLICT DO NOTHING;\n"
        f.write(sql)
    f.write("\n")

    # 2. PRACOWNICY
    # Generujemy 50 pracowników
    pracownik_ids = []
    used_pesels = set()
    # Dodajemy "start=4", żeby nie nadpisać Jana, Anny i Piotra
    for i in range(4, 54): 
        plec = random.choice(['M', 'K'])
        if plec == 'M':
            imie = fake.first_name_male()
            nazwisko = fake.last_name_male()
        else:
            imie = fake.first_name_female()
            nazwisko = fake.last_name_female()
        
        # Generowanie unikalnego poprawnego PESELu
        while True:
            pesel = fake.pesel()
            if pesel not in used_pesels:
                used_pesels.add(pesel)
                break
        
        stanowiska = ['Specjalista', 'Starszy Specjalista', 'Młodszy Specjalista', 'Kierownik', 'Asystent']
        stanowisko = random.choice(stanowiska)
        jednostka = random.randint(1, 8) # Mamy 3 stare + 5 nowych
        data_zatr = fake.date_between(start_date='-5y', end_date='-1y')
        stawka = round(random.uniform(25.00, 80.00), 2)
        telefon = f"{random.randint(500,999)}-{random.randint(100,999)}-{random.randint(100,999)}"
        umowa = random.choice(['UoP', 'B2B', 'Zlecenie'])
        
        sql = f"INSERT INTO pracownicy (pracownik_id, imie, nazwisko, pesel, data_urodzenia, stanowisko, jednostka_id, data_zatrudnienia, stawka_godzinowa, typ_umowy, wymiar_etatu, telefon_kontaktowy) VALUES ({i}, '{imie}', '{nazwisko}', '{pesel}', '{fake.date_of_birth(minimum_age=18, maximum_age=60)}', '{stanowisko}', {jednostka}, '{data_zatr}', {stawka}, '{umowa}', 1.00, '{telefon}');\n"
        f.write(sql)
        pracownik_ids.append(i)
    f.write("\n")

    # 3. KLIENCI
    klient_ids = []
    f.write("-- Generowanie Klientów\n")
    for i in range(3, 23): # Start od 3
        firma = fake.company().replace("'", "")
        nip = fake.nip().replace("-", "")
        adres = fake.address().replace('\n', ', ').replace("'", "")
        sql = f"INSERT INTO klienci (klient_id, nazwa_klienta, nip, adres) VALUES ({i}, '{firma}', '{nip}', '{adres}') ON CONFLICT DO NOTHING;\n"
        f.write(sql)
        klient_ids.append(i)
    f.write("\n")

    # 4. ZLECENIA
    f.write("-- Generowanie Zleceń\n")
    produkty = ['Profil stalowy', 'Rura PCV', 'Kątownik', 'Blacha miedziana', 'Śruba M12', 'Nakrętka M10']
    for i in range(4, 104):
        klient = random.choice(klient_ids)
        nr_zlec = f"ZLEC/{fake.year()}/{random.randint(1000,9999)}"
        data_przyjecia = date(2025, 8, random.randint(1, 28))
        data_real = data_przyjecia + timedelta(days=random.randint(5, 20))
        
        # Czy zakończone? (Większość tak, żeby były w raporcie wrześniowym)
        zakonczona = random.choice([True, True, True, False])
        data_faktyczna = "NULL"
        if zakonczona:
            # Losujemy datę we wrześniu 2025
            data_faktyczna = f"'{date(2025, 9, random.randint(1, 30))}'"
        
        produkt = random.choice(produkty)
        ilosc = random.randint(100, 5000)
        cena = round(random.uniform(1.50, 50.00), 2)
        
        sql = f"INSERT INTO zlecenia_produkcyjne (zlecenie_id, klient_id, numer_zlecenia_klienta, data_przyjecia_zlecenia, przewidywana_data_realizacji, data_faktycznej_realizacji, nazwa_produktu, ilosc, cena_jednostkowa, waluta, jednostka_id, czy_zakonczona) VALUES ({i}, {klient}, '{nr_zlec}', '{data_przyjecia}', '{data_real}', {data_faktyczna}, '{produkt}', {ilosc}, {cena}, 'PLN', 1, {str(zakonczona).upper()}) ON CONFLICT DO NOTHING;\n"
        f.write(sql)
    f.write("\n")

    # 5. CZAS PRACY (Masowe wpisy na Wrzesień 2025)
    f.write("-- Generowanie Czasu Pracy\n")
    rejestr_id = 100 # Startujemy od 100
    # Dla każdego pracownika generujemy 20 dni pracy we wrześniu
    for pracownik in pracownik_ids:
        for dzien in range(1, 22): # Dni robocze (uproszczenie)
            if dzien in [6, 7, 13, 14, 20, 21, 27, 28]: continue # Omijamy weekendy (prosty filtr)
            
            data_pracy = date(2025, 9, dzien)
            godziny = random.choice([8, 8, 8, 7, 6, 8, 8.5, 9]) # Czasami nadgodziny, czasami mniej
            
            sql = f"INSERT INTO rejestr_czasu_pracy (rejestr_id, pracownik_id, data_pracy, godziny_przepracowane) VALUES ({rejestr_id}, {pracownik}, '{data_pracy}', {godziny});\n"
            f.write(sql)
            rejestr_id += 1
    
    f.write("COMMIT;\n")

print(f"Sukces! Wygenerowano plik: {output_file}")