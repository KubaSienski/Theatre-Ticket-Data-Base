DROP DATABASE IF EXISTS teatr_jakub_sienski;

CREATE DATABASE teatr_jakub_sienski;

USE teatr_jakub_sienski;

CREATE TABLE klienci
(	id_k	int 			not null AUTO_INCREMENT,
	primary key 	(id_k),

	imie		varchar(20) 		not null,
	nazwisko	varchar(30) 		not null,
	email		varchar(60)		not null,
	nr_tel	varchar(9)			not null
);

CREATE TABLE spektakle
(	id_sp	int 			not null AUTO_INCREMENT,
	primary key 	(id_sp),

	tytul		varchar(40) 		not null,
	rezyser		varchar(60) 		not null,
	ilu_aktorow	int			not null,
	grupa_wiekowa	varchar(10)		not null,
	cena		decimal(5,2)		not null
);

CREATE TABLE sale
(	id_s	int 			not null AUTO_INCREMENT,
	primary key 	(id_s),

	nr		int	 		not null,
	ilosc_sektorow	int		 	not null,
	ilosc_miejsc	int		 	not null
);

CREATE TABLE bilety 
(	id_b	int 			not null AUTO_INCREMENT,
	primary key 	(id_b),
	id_k 	int 			not null,
	foreign key  	(id_k)		references klienci(id_k),
	id_sp 	int			not null,
	foreign key 	(id_sp) 	references spektakle(id_sp),
	id_s 	int			not null,
	foreign key 	(id_s) 		references sale(id_s),

	sektor		varchar(1)		not null,
	nr_miejsca	int 			not null,
	data		datetime 		not null
);

CREATE TABLE logi
(	id_l	int 			UNSIGNED not null AUTO_INCREMENT,
	primary key 	(id_l),

	operacja 	VARCHAR(30),
	czas 		DATETIME
);

-- tworzenie indeksów

CREATE INDEX idx_klienci_nazwisko ON klienci (nazwisko);
CREATE INDEX idx_bilety_data ON bilety (data);
CREATE INDEX idx_spektakle_tytul_grupa_wiekowa ON spektakle (tytul, grupa_wiekowa);

-- tworzenie wyzwalaczy

DELIMITER //
CREATE TRIGGER before_bilety_insert
BEFORE INSERT ON bilety
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM bilety
        WHERE data = NEW.data
        AND nr_miejsca = NEW.nr_miejsca
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Miejsce jest już zajęte.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_bilety_update
BEFORE UPDATE ON bilety
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM bilety
        WHERE data = NEW.data
        AND nr_miejsca = NEW.nr_miejsca
        AND id_b != NEW.id_b
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Miejsce jest już zajęte.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_klienci_insert
AFTER INSERT ON klienci
FOR EACH ROW
BEGIN
    INSERT INTO logi (operacja, czas)
    VALUES ('Dodano rekord do tabeli klienci', NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_klienci_delete
AFTER DELETE ON klienci
FOR EACH ROW
BEGIN
    INSERT INTO logi (operacja, czas)
    VALUES ('Usunięto rekord z tabeli klienci', NOW());
END //
DELIMITER ;

-- procedura pokazująca ilość klientów

DELIMITER //
CREATE PROCEDURE ile_klienci()
BEGIN
  SELECT COUNT(*) AS liczba_rekordow FROM klienci;
END //
DELIMITER ;

-- procedura pokazująca bilety klienta o danym nazwisku

DELIMITER //
CREATE PROCEDURE bilety_klienta(IN nazwisko_param VARCHAR(30))
BEGIN
  SELECT k.imie, k.nazwisko, b.sektor, b.nr_miejsca, b.data
  FROM bilety b
  INNER JOIN klienci k ON b.id_k = k.id_k
  WHERE k.nazwisko = nazwisko_param;
END //
DELIMITER ;

-- wprowadzanie danych

INSERT INTO klienci (imie, nazwisko, email, nr_tel)
VALUES
  ('Jan', 'Kowalski', 'jan.kowalski@gmail.com', '123456789'),
  ('Anna', 'Nowak', 'anna.nowak@gmail.com', '234567890'),
  ('Piotr', 'Wiśniewski', 'piotr.wisniewski@o2.com', '102302993'),
  ('Maria', 'Wójcik', 'maria.wojcik@gmail.com', '102333929'),
  ('Andrzej', 'Kowalczyk', 'andrzej.kowalczyk@o2.com', '537721829'),
  ('Katarzyna', 'Kamińska', 'katarzyna.kaminska@gmail.com', '685994832'),
  ('Tomasz', 'Lewandowski', 'tomasz.lewandowski@gmail.com', '784169012'),
  ('Magdalena', 'Zielińska', 'magdalena.zielinska@gmail.com', '859011223'),
  ('Paweł', 'Szymański', 'pawel.szymanski@wp.com', '902512534'),
  ('Małgorzata', 'Woźniak', 'malgorzata.wozniak@gmail.com', '012234145'),
  ('Michał', 'Dąbrowski', 'michal.dabrowski@gmail.com', '123144450'),
  ('Joanna', 'Kozłowska', 'joanna.kozlowska@gmail.com', '523416561'),
  ('Grzegorz', 'Jankowski', 'grzegorz.jankowski@o2.com', '434256672'),
  ('Ewa', 'Mazur', 'ewa.mazur@gmail.com', '451617583'),
  ('Adam', 'Kwiatkowski', 'adam.kwiatkowski@gmail.com', '561755894');

INSERT INTO spektakle (tytul, rezyser, ilu_aktorow, grupa_wiekowa, cena)
VALUES
  ('Zaklęte serce', 'Kacper Lewandowski', 5, 'dorośli', 50),
  ('Magiczna podróż', 'Aleksandra Nowak', 3, 'dzieci', 45),
  ('Tajemnica zamku', 'Adam Wiśniewski', 8, 'wszyscy', 39.50),
  ('Skrzat w lesie', 'Maria Kowalik', 4, 'dzieci', 50),
  ('Sekretne spotkanie', 'Andrzej Kowalczyk', 6, 'dorośli', 55),
  ('Podwodna przygoda', 'Katarzyna Kamińska', 2, 'dzieci', 35),
  ('W krainie czarów', 'Andrzej Lewandowski', 7, 'wszyscy', 55),
  ('Wyspa skarbów', 'Karolina Zielińska', 4, 'dzieci', 70),
  ('Zaginiony skarb', 'Paweł Kowalski', 6, 'dorośli', 80),
  ('Sekretne agentki', 'Małgorzata Woźniak', 3, 'dzieci', 45),
  ('Tajemnicza misja', 'Andrzej Dąbrowski', 5, 'wszyscy', 60),
  ('Zaklęte pióro', 'Joanna Kozłowska', 4, 'dorośli', 100),
  ('Skarby piratów', 'Maksymilian Szymański', 6, 'dzieci', 50),
  ('Wyścig samochodowy', 'Ewa Mazur', 2, 'wszyscy', 35),
  ('Sztuka układania', 'Adam Kwiatkowski', 4, 'dorośli', 45.50);

INSERT INTO sale (nr, ilosc_sektorow, ilosc_miejsc)
VALUES 
  (1, 1, 20),
  (2, 1, 20),
  (3, 2, 30),
  (4, 2, 30),
  (5, 2, 50),
  (6, 2, 50),
  (7, 4, 80),
  (8, 4, 80),
  (9, 4, 80),
  (10, 4, 100),
  (11, 6, 150);


INSERT INTO bilety (id_k, id_sp, id_s, sektor, nr_miejsca, data)
VALUES 
  (1,	 	11, 	1, 	'A', 	13, 	'2020-04-13 19:00'),
  (2,	 	11, 	1, 	'A', 	18, 	'2020-04-13 19:00'),
  (3,	 	11, 	1, 	'A', 	4, 	'2020-04-13 19:00'),
  (4,	 	4, 	4, 	'B', 	1, 	'2020-04-14 18:00'),
  (5,	 	3, 	5, 	'A', 	5, 	'2020-04-10 18:00'),
  (6,		5, 	6, 	'A', 	6, 	'2020-04-13 18:00'),
  (7,		6, 	7, 	'D', 	45, 	'2020-04-13 18:00'),
  (8, 		8, 	8, 	'C', 	75, 	'2020-04-13 18:00'),
  (9, 		7, 	9, 	'A', 	54, 	'2020-04-20 18:00'),
  (10, 		9, 	10, 	'D', 	16, 	'2020-04-13 18:00'),
  (11, 		10, 	11, 	'E', 	100, 	'2020-04-13 18:00'),
  (12, 		1, 	1, 	'A', 	5, 	'2020-04-12 18:00'),
  (13, 		12, 	2, 	'A', 	8, 	'2020-04-13 18:00'),
  (14, 		13, 	3, 	'B', 	10, 	'2020-04-14 18:00'),
  (15, 		14, 	4, 	'B', 	11, 	'2020-04-13 18:00'),
  (1, 		15, 	5, 	'A', 	12, 	'2020-04-11 19:00'),
  (1, 		7, 	9, 	'B', 	27, 	'2020-04-20 18:00'),
  (3, 		12, 	7, 	'C', 	28, 	'2020-04-12 17:00'),
  (5, 		8, 	8, 	'A', 	29, 	'2020-04-13 18:00'),
  (8, 		1, 	9, 	'D', 	30, 	'2020-04-15 16:00');

-- liczba biletów sprzedanych dla klienta o nazwisku Kowalski posortowane po tytule

SELECT s.tytul, COUNT(*) AS liczba_biletow
FROM spektakle s, bilety b, klienci k
WHERE s.id_sp = b.id_sp
  AND b.id_k = k.id_k
  AND k.nazwisko = 'Kowalski'
GROUP BY s.tytul;

-- Zwraca liczbę biletów sprzedanych dla spektakli, grupując wyniki po tytule i wyświetlając tylko te, które mają więcej niż 2 sprzedane bilety, posortowane malejąco

SELECT s.tytul, COUNT(*) AS liczba_biletow
FROM bilety b
NATURAL JOIN spektakle s
GROUP BY s.tytul
HAVING COUNT(*) > 2
ORDER BY COUNT(*) DESC;

-- Oblicza sumę cen biletów dla klientów, którzy zakupili bilety na spektakle z zakresem liczby aktorów od 5 do 10

SELECT k.imie, k.nazwisko, SUM(s.cena) AS suma_cen_biletow
FROM klienci k
INNER JOIN bilety b ON k.id_k = b.id_k
INNER JOIN spektakle s ON b.id_sp = s.id_sp
WHERE s.ilu_aktorow BETWEEN 5 AND 10
GROUP BY k.imie, k.nazwisko;

-- Zwraca liczbę biletów sprzedanych klientom, oraz ich imiona i nazwiska, na spektakle, ktorych nazwisko rezysera zawiera slowo 'Kowal'

SELECT k.imie, k.nazwisko, COUNT(b.id_b) AS liczba_biletow
FROM klienci k
LEFT OUTER JOIN bilety b ON k.id_k = b.id_k
LEFT OUTER JOIN spektakle s ON b.id_sp = s.id_sp
WHERE s.rezyser LIKE '%Kowal%'
GROUP BY k.imie, k.nazwisko;

-- Oblicza sumę cen biletów dla każdego spektaklu, uwzględniając również spektakle, dla których nie sprzedano żadnego biletu, i sortuje wyniki malejąco według sumy cen

SELECT s.tytul, SUM(s.cena) AS suma_cen_biletow
FROM bilety b
RIGHT OUTER JOIN spektakle s ON b.id_sp = s.id_sp
GROUP BY s.tytul
ORDER BY suma_cen_biletow DESC;