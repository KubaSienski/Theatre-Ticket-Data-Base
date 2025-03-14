# Theatre Ticket Database

## Overview
This database manages theatre ticket bookings, customers, performances, halls, and sales transactions. It includes constraints, triggers, stored procedures, and indexing for efficient operations.

## Database Structure

### Clients (`klienci`)
Stores customer details.

```sql
CREATE TABLE klienci (
    id_k INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    imie VARCHAR(20) NOT NULL,
    nazwisko VARCHAR(30) NOT NULL,
    email VARCHAR(60) NOT NULL,
    nr_tel VARCHAR(9) NOT NULL
);
```

### Performances (`spektakle`)
Stores details of theatrical performances.

```sql
CREATE TABLE spektakle (
    id_sp INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tytul VARCHAR(40) NOT NULL,
    rezyser VARCHAR(60) NOT NULL,
    ilu_aktorow INT NOT NULL,
    grupa_wiekowa VARCHAR(10) NOT NULL,
    cena DECIMAL(5,2) NOT NULL
);
```

### Halls (`sale`)
Stores information about theatre halls.

```sql
CREATE TABLE sale (
    id_s INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nr INT NOT NULL,
    ilosc_sektorow INT NOT NULL,
    ilosc_miejsc INT NOT NULL
);
```

### Tickets (`bilety`)
Manages ticket sales, linking customers, performances, and halls.

```sql
CREATE TABLE bilety (
    id_b INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_k INT NOT NULL,
    id_sp INT NOT NULL,
    id_s INT NOT NULL,
    sektor VARCHAR(1) NOT NULL,
    nr_miejsca INT NOT NULL,
    data DATETIME NOT NULL,
    FOREIGN KEY (id_k) REFERENCES klienci(id_k),
    FOREIGN KEY (id_sp) REFERENCES spektakle(id_sp),
    FOREIGN KEY (id_s) REFERENCES sale(id_s)
);
```

### Logs (`logi`)
Stores logs of operations.

```sql
CREATE TABLE logi (
    id_l INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    operacja VARCHAR(30),
    czas DATETIME
);
```

## Indexing

```sql
CREATE INDEX idx_klienci_nazwisko ON klienci (nazwisko);
CREATE INDEX idx_bilety_data ON bilety (data);
CREATE INDEX idx_spektakle_tytul_grupa_wiekowa ON spektakle (tytul, grupa_wiekowa);
```

## Triggers
Ensuring ticket constraints and logging operations.

```sql
DELIMITER //
CREATE TRIGGER before_bilety_insert
BEFORE INSERT ON bilety
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM bilety
        WHERE data = NEW.data AND nr_miejsca = NEW.nr_miejsca
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Miejsce jest już zajęte.';
    END IF;
END //
DELIMITER ;
```

## Stored Procedures

### Count Clients
```sql
DELIMITER //
CREATE PROCEDURE ile_klienci()
BEGIN
    SELECT COUNT(*) AS liczba_rekordow FROM klienci;
END //
DELIMITER ;
```

### Retrieve Client's Tickets
```sql
DELIMITER //
CREATE PROCEDURE bilety_klienta(IN nazwisko_param VARCHAR(30))
BEGIN
    SELECT k.imie, k.nazwisko, b.sektor, b.nr_miejsca, b.data
    FROM bilety b
    INNER JOIN klienci k ON b.id_k = k.id_k
    WHERE k.nazwisko = nazwisko_param;
END //
DELIMITER ;
```

## Queries

### Tickets Sold to "Kowalski"
```sql
SELECT s.tytul, COUNT(*) AS liczba_biletow
FROM spektakle s, bilety b, klienci k
WHERE s.id_sp = b.id_sp
  AND b.id_k = k.id_k
  AND k.nazwisko = 'Kowalski'
GROUP BY s.tytul;
```

### Most Sold Performances
```sql
SELECT s.tytul, COUNT(*) AS liczba_biletow
FROM bilety b
NATURAL JOIN spektakle s
GROUP BY s.tytul
HAVING COUNT(*) > 2
ORDER BY COUNT(*) DESC;
```

### Total Ticket Revenue by Performance
```sql
SELECT s.tytul, SUM(s.cena) AS suma_cen_biletow
FROM bilety b
RIGHT OUTER JOIN spektakle s ON b.id_sp = s.id_sp
GROUP BY s.tytul
ORDER BY suma_cen_biletow DESC;
```

## Conclusion
This database efficiently manages theatre ticket sales, ensures data integrity with constraints, and provides reporting capabilities through optimized queries and procedures.

