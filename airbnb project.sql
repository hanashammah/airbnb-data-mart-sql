DROP DATABASE IF EXISTS airbnb_db;
CREATE DATABASE airbnb_db;
USE airbnb_db;


-- User Table
CREATE TABLE UserAccount (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Password VARCHAR(255) NOT NULL,
    UserType ENUM('Guest','Host','Admin') NOT NULL,
    CreatedDate DATE DEFAULT (CURRENT_DATE)
);
-- Guest Table
CREATE TABLE Guest (
    GuestID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    DateOfBirth DATE,
    PreferredLanguage VARCHAR(50),
    GDPRConsent BOOLEAN DEFAULT TRUE,
    FOREIGN KEY(UserID) REFERENCES UserAccount(UserID)
);

-- Host Table
CREATE TABLE Host (
    HostID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    Rating DECIMAL(3,2),
	CHECK(Rating BETWEEN 0 AND 5),
    VerificationStatus ENUM('Pending', 'Verified', 'Rejected') DEFAULT 'Pending',
    Bio TEXT,
	FOREIGN KEY(UserID) REFERENCES UserAccount(UserID)
);

-- city Table
CREATE TABLE IF NOT EXISTS City (
    CityID INT PRIMARY KEY AUTO_INCREMENT,
    CityName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL
);

-- Location Table
CREATE TABLE IF NOT EXISTS Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    Address VARCHAR(255),
    PartOfCity VARCHAR(100),
    CityID INT NOT NULL,
    FOREIGN KEY (CityID) REFERENCES City(CityID)
);

-- VacationRental Table
CREATE TABLE IF NOT EXISTS VacationRental (
    VacationRentalID INT PRIMARY KEY AUTO_INCREMENT,
    HostID INT NOT NULL,
    PropertyType VARCHAR(50) NOT NULL,
    LocationID INT NOT NULL,
    NumberOfRooms INT,             
    MaxGuests INT,
    PricePerNight DECIMAL(8,2) NOT NULL,
    Rating DECIMAL(3,2),
	CHECK(Rating BETWEEN 0 AND 5),
    Description TEXT,             
    CheckInTime TIME,              
    CheckOutTime TIME,
    FOREIGN KEY (HostID) REFERENCES Host(HostID),
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- PaymentMethod Table
DROP TABLE IF EXISTS PaymentMethod;
CREATE TABLE PaymentMethod (
    PaymentMethodID INT PRIMARY KEY AUTO_INCREMENT,
    MethodName VARCHAR(50) NOT NULL UNIQUE,
    Description TEXT
);

-- Room Table
CREATE TABLE IF NOT EXISTS Room (
    RoomID INT PRIMARY KEY AUTO_INCREMENT,
    VacationRentalID INT NOT NULL,
    NightPrice DECIMAL(8,2),
    RoomType VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    FOREIGN KEY (VacationRentalID) REFERENCES VacationRental(VacationRentalID)
);

-- Booking Table
CREATE TABLE IF NOT EXISTS Booking (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    GuestID INT NOT NULL,
    RoomID INT NOT NULL,
    BookingDate DATE NOT NULL,
    DurationInNights INT NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    CancellationDeadline DATE NOT NULL,
    TotalPrice DECIMAL(8,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL,
    PaymentMethodID INT,
    NumberOfGuests INT,
    SpecialRequests TEXT, 
	FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID),
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

-- Review Table
DROP TABLE IF EXISTS Review;
CREATE TABLE Review(
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
	BookingID INT NOT NULL UNIQUE,
    GuestID INT NOT NULL,
    VacationRentalID INT NOT NULL,
    Rating DECIMAL(2,1) CHECK(Rating BETWEEN 0 AND 5),
    ReviewDate DATE,
    Comment TEXT,
    Response TEXT,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
    FOREIGN KEY (VacationRentalID) REFERENCES VacationRental(VacationRentalID)
);

-- Transactions Table
CREATE TABLE IF NOT EXISTS Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT NOT NULL,
    GuestID INT NOT NULL,
    PaymentMethodID INT NOT NULL,
    TransactionType ENUM('Payment', 'Refund') NOT NULL,
    TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(8,2) NOT NULL CHECK (Amount > 0),
    Currency VARCHAR(10) DEFAULT 'USD',
    Description TEXT,
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID)
);

-- Promotoin Table
CREATE TABLE IF NOT EXISTS Promotion (
    PromotionID INT PRIMARY KEY AUTO_INCREMENT,
    VacationRentalID INT NOT NULL,
    DiscountPercentage DECIMAL(5,2),
    PromoCode VARCHAR(50),
    MinNights INT,
    StartDate DATE,
    EndDate DATE,
    Description TEXT,
    FOREIGN KEY (VacationRentalID) REFERENCES VacationRental(VacationRentalID)
);

-- Amenity Table
CREATE TABLE IF NOT EXISTS Amenity (
    AmenityID INT PRIMARY KEY AUTO_INCREMENT,
    AmenityName VARCHAR(50) NOT NULL,
    Description TEXT
);

-- VacationRentalAmenity Table
CREATE TABLE IF NOT EXISTS VacationRentalAmenity (
    VacationRentalID INT NOT NULL,
    AmenityID INT NOT NULL,
	IsAvailable BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (VacationRentalID, AmenityID),
    FOREIGN KEY (VacationRentalID) REFERENCES VacationRental(VacationRentalID),
    FOREIGN KEY (AmenityID) REFERENCES Amenity(AmenityID)
);

-- CancellationPolicy Table
CREATE TABLE IF NOT EXISTS CancellationPolicy (
    PolicyID INT PRIMARY KEY AUTO_INCREMENT,
    PolicyName VARCHAR(50) NOT NULL,
    RefundPercentage DECIMAL(5,2) NOT NULL,
    Description TEXT
);

-- VacationRentalPolicy Table
CREATE TABLE IF NOT EXISTS VacationRentalPolicy (
    VacationRentalID INT NOT NULL,
    PolicyID INT NOT NULL,
    PRIMARY KEY (VacationRentalID, PolicyID),
    FOREIGN KEY (VacationRentalID) REFERENCES VacationRental(VacationRentalID),
    FOREIGN KEY (PolicyID) REFERENCES CancellationPolicy(PolicyID)
);

-- CustomerService Table
CREATE TABLE CustomerService (
    ServiceID INT AUTO_INCREMENT PRIMARY KEY,
    BookingID INT NOT NULL,
    GuestID INT NOT NULL,
    HostID INT NOT NULL,
    IssueDescription TEXT,
    IssueCategory VARCHAR(100),
    ReportDate DATE,
    Resolution TEXT,
    ResolutionStatus VARCHAR(50),
    ContactMethod VARCHAR(50),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
	FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
	FOREIGN KEY (HostID) REFERENCES Host(HostID)
);
-- Event Table
CREATE TABLE IF NOT EXISTS Event (
    EventID INT PRIMARY KEY AUTO_INCREMENT,
    VacationRentalID INT NOT NULL,
    HostID INT NOT NULL,
    EventName VARCHAR(100) NOT NULL,
    Capacity INT,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Description TEXT,
    FOREIGN KEY (VacationRentalID) REFERENCES VacationRental(VacationRentalID),
	FOREIGN KEY (HostID) REFERENCES Host(HostID)
);

-- Notification Table
CREATE TABLE IF NOT EXISTS Notification (
    NotificationID INT PRIMARY KEY AUTO_INCREMENT,
    GuestID INT,
    HostID INT,
    Message TEXT NOT NULL,
    DateSent DATE,
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
    FOREIGN KEY (HostID) REFERENCES Host(HostID)
);

-- LoginHistory Table
DROP TABLE IF EXISTS LoginHistory;
CREATE TABLE LoginHistory (
    LoginID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    UserType ENUM('Guest', 'Host', 'Admin') NOT NULL,
    LoginDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    LogoutDate DATETIME,
    LoginStatus ENUM('Success', 'Failed') DEFAULT 'Success',
    FOREIGN KEY(UserID)
    REFERENCES UserAccount(UserID)
);

-- SocialNetwork Table
CREATE TABLE IF NOT EXISTS SocialNetwork (
    SocialNetworkID INT PRIMARY KEY AUTO_INCREMENT,
    NetworkName VARCHAR(50) NOT NULL,
    NetworkURL VARCHAR(255)
);

-- GuestSocailNetwork Table
CREATE TABLE IF NOT EXISTS GuestSocialNetwork (
    GuestID INT NOT NULL,
    SocialNetworkID INT NOT NULL,
    ProfileLink VARCHAR(255),
    Username VARCHAR(100),
    Verified BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (GuestID, SocialNetworkID),
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
    FOREIGN KEY (SocialNetworkID) REFERENCES SocialNetwork(SocialNetworkID)
);

-- SimilarRental Table (Recursive Relationship)
CREATE TABLE IF NOT EXISTS SimilarRental (
    VacationRentalID INT NOT NULL,
    SimilarRentalID INT NOT NULL,
	PRIMARY KEY (VacationRentalID, SimilarRentalID),
    FOREIGN KEY (VacationRentalID) REFERENCES VacationRental(VacationRentalID),
    FOREIGN KEY (SimilarRentalID) REFERENCES VacationRental(VacationRentalID),
    CHECK (VacationRentalID <> SimilarRentalID)
);


USE airbnb_db;

-- Inserting dummy data for testing purposes to verify table structures and relationships


-- USERS
INSERT INTO UserAccount (FullName, Email, Phone, Password, UserType)
VALUES
('Guest1 Last1','guest1@example.com','1111111111','pass1','Guest'),
('Guest2 Last2','guest2@example.com','1111111112','pass2','Guest'),
('Guest3 Last3','guest3@example.com','1111111113','pass3','Guest'),
('Guest4 Last4','guest4@example.com','1111111114','pass4','Guest'),
('Guest5 Last5','guest5@example.com','1111111115','pass5','Guest'),
('Guest6 Last6','guest6@example.com','1111111116','pass6','Guest'),
('Guest7 Last7','guest7@example.com','1111111117','pass7','Guest'),
('Guest8 Last8','guest8@example.com','1111111118','pass8','Guest'),
('Guest9 Last9','guest9@example.com','1111111119','pass9','Guest'),
('Guest10 Last10','guest10@example.com','1111111120','pass10','Guest'),
('Guest11 Last11','guest11@example.com','1111111121','pass11','Guest'),
('Guest12 Last12','guest12@example.com','1111111122','pass12','Guest'),
('Guest13 Last13','guest13@example.com','1111111123','pass13','Guest'),
('Guest14 Last14','guest14@example.com','1111111124','pass14','Guest'),
('Guest15 Last15','guest15@example.com','1111111125','pass15','Guest'),
('Guest16 Last16','guest16@example.com','1111111126','pass16','Guest'),
('Guest17 Last17','guest17@example.com','1111111127','pass17','Guest'),
('Guest18 Last18','guest18@example.com','1111111128','pass18','Guest'),
('Guest19 Last19','guest19@example.com','1111111129','pass19','Guest'),
('Guest20 Last20','guest20@example.com','1111111130','pass20','Guest'),

('Host1','host1@example.com','2221110001','pass21','Host'),
('Host2','host2@example.com','2221110002','pass22','Host'),
('Host3','host3@example.com','2221110003','pass23','Host'),
('Host4','host4@example.com','2221110004','pass24','Host'),
('Host5','host5@example.com','2221110005','pass25','Host'),
('Host6','host6@example.com','2221110006','pass26','Host'),
('Host7','host7@example.com','2221110007','pass27','Host'),
('Host8','host8@example.com','2221110008','pass28','Host'),
('Host9','host9@example.com','2221110009','pass29','Host'),
('Host10','host10@example.com','2221110010','pass30','Host'),
('Host11','host11@example.com','2221110011','pass31','Host'),
('Host12','host12@example.com','2221110012','pass32','Host'),
('Host13','host13@example.com','2221110013','pass33','Host'),
('Host14','host14@example.com','2221110014','pass34','Host'),
('Host15','host15@example.com','2221110015','pass35','Host'),
('Host16','host16@example.com','2221110016','pass36','Host'),
('Host17','host17@example.com','2221110017','pass37','Host'),
('Host18','host18@example.com','2221110018','pass38','Host'),
('Host19','host19@example.com','2221110019','pass39','Host'),
('Host20','host20@example.com','2221110020','pass40','Host');


-- GUESTS
INSERT INTO Guest (UserID, DateOfBirth, PreferredLanguage, GDPRConsent)
VALUES
(1,'1990-01-01','English',TRUE),
(2,'1991-02-02','English',TRUE),
(3,'1992-03-03','French',TRUE),
(4,'1993-04-04','Spanish',TRUE),
(5,'1994-05-05','German',TRUE),
(6,'1995-06-06','English',TRUE),
(7,'1996-07-07','French',TRUE),
(8,'1997-08-08','Spanish',TRUE),
(9,'1998-09-09','German',TRUE),
(10,'1999-10-10','English',TRUE),
(11,'1990-11-11','English',TRUE),
(12,'1991-12-12','French',TRUE),
(13,'1992-01-13','Spanish',TRUE),
(14,'1993-02-14','German',TRUE),
(15,'1994-03-15','English',TRUE),
(16,'1995-04-16','French',TRUE),
(17,'1996-05-17','Spanish',TRUE),
(18,'1997-06-18','German',TRUE),
(19,'1998-07-19','English',TRUE),
(20,'1999-08-20','French',TRUE);


-- HOSTS
INSERT INTO Host (UserID, Rating, VerificationStatus, Bio)
VALUES
(21,4.5,'Verified','Bio of host1'),
(22,4.6,'Verified','Bio of host2'),
(23,4.7,'Pending','Bio of host3'),
(24,4.8,'Verified','Bio of host4'),
(25,4.9,'Verified','Bio of host5'),
(26,4.5,'Pending','Bio of host6'),
(27,4.6,'Verified','Bio of host7'),
(28,4.7,'Verified','Bio of host8'),
(29,4.8,'Verified','Bio of host9'),
(30,4.9,'Pending','Bio of host10'),
(31,4.5,'Verified','Bio of host11'),
(32,4.6,'Verified','Bio of host12'),
(33,4.7,'Verified','Bio of host13'),
(34,4.8,'Pending','Bio of host14'),
(35,4.9,'Verified','Bio of host15'),
(36,4.5,'Verified','Bio of host16'),
(37,4.6,'Pending','Bio of host17'),
(38,4.7,'Verified','Bio of host18'),
(39,4.8,'Verified','Bio of host19'),
(40,4.9,'Verified','Bio of host20');

-- CITIES
INSERT INTO City (CityName, Country)
VALUES
('City1','Country1'),('City2','Country2'),('City3','Country3'),('City4','Country4'),('City5','Country5'),
('City6','Country6'),('City7','Country7'),('City8','Country8'),('City9','Country9'),('City10','Country10'),
('City11','Country11'),('City12','Country12'),('City13','Country13'),('City14','Country14'),('City15','Country15'),
('City16','Country16'),('City17','Country17'),('City18','Country18'),('City19','Country19'),('City20','Country20');


-- LOCATIONS
INSERT INTO Location (CityID, Address, PartOfCity)
VALUES
(1,'Address1','Part1'),(2,'Address2','Part2'),(3,'Address3','Part3'),(4,'Address4','Part4'),(5,'Address5','Part5'),
(6,'Address6','Part6'),(7,'Address7','Part7'),(8,'Address8','Part8'),(9,'Address9','Part9'),(10,'Address10','Part10'),
(11,'Address11','Part11'),(12,'Address12','Part12'),(13,'Address13','Part13'),(14,'Address14','Part14'),(15,'Address15','Part15'),
(16,'Address16','Part16'),(17,'Address17','Part17'),(18,'Address18','Part18'),(19,'Address19','Part19'),(20,'Address20','Part20');


-- VACATION RENTALS
INSERT INTO VacationRental (HostID, PropertyType, LocationID, PricePerNight, NumberOfRooms, MaxGuests, Description, Rating, CheckInTime, CheckOutTime)
VALUES
(1,'Apartment',1,100.00,2,4,'Desc1',4.5,'15:00:00','11:00:00'),
(2,'Apartment',2,120.00,2,4,'Desc2',4.6,'15:00:00','11:00:00'),
(3,'House',3,150.00,3,6,'Desc3',4.7,'15:00:00','11:00:00'),
(4,'House',4,180.00,3,6,'Desc4',4.8,'15:00:00','11:00:00'),
(5,'Villa',5,200.00,4,8,'Desc5',4.9,'15:00:00','11:00:00'),
(6,'Villa',6,210.00,4,8,'Desc6',4.5,'15:00:00','11:00:00'),
(7,'Apartment',7,130.00,2,4,'Desc7',4.6,'15:00:00','11:00:00'),
(8,'House',8,160.00,3,6,'Desc8',4.7,'15:00:00','11:00:00'),
(9,'Apartment',9,140.00,2,4,'Desc9',4.8,'15:00:00','11:00:00'),
(10,'Villa',10,220.00,4,8,'Desc10',4.9,'15:00:00','11:00:00'),
(11,'Apartment',11,110.00,2,4,'Desc11',4.5,'15:00:00','11:00:00'),
(12,'House',12,170.00,3,6,'Desc12',4.6,'15:00:00','11:00:00'),
(13,'Apartment',13,125.00,2,4,'Desc13',4.7,'15:00:00','11:00:00'),
(14,'House',14,160.00,3,6,'Desc14',4.8,'15:00:00','11:00:00'),
(15,'Villa',15,230.00,4,8,'Desc15',4.9,'15:00:00','11:00:00'),
(16,'Villa',16,240.00,4,8,'Desc16',4.5,'15:00:00','11:00:00'),
(17,'Apartment',17,135.00,2,4,'Desc17',4.6,'15:00:00','11:00:00'),
(18,'House',18,180.00,3,6,'Desc18',4.7,'15:00:00','11:00:00'),
(19,'Apartment',19,145.00,2,4,'Desc19',4.8,'15:00:00','11:00:00'),
(20,'Villa',20,250.00,4,8,'Desc20',4.9,'15:00:00','11:00:00');


-- ROOMS
INSERT INTO Room (VacationRentalID, RoomType, Capacity, NightPrice)
VALUES
(1,'Double',2,100.00),(2,'Double',2,120.00),(3,'Suite',4,150.00),(4,'Double',2,180.00),(5,'Suite',4,200.00),
(6,'Double',2,210.00),(7,'Suite',4,130.00),(8,'Double',2,160.00),(9,'Suite',4,140.00),(10,'Double',2,220.00),
(11,'Suite',4,110.00),(12,'Double',2,170.00),(13,'Suite',4,125.00),(14,'Double',2,160.00),(15,'Suite',4,230.00),
(16,'Double',2,240.00),(17,'Suite',4,135.00),(18,'Double',2,180.00),(19,'Suite',4,145.00),(20,'Double',2,250.00);


-- PAYMENT METHODS
INSERT INTO PaymentMethod (MethodName, Description)
VALUES
('Cash','Payment made in cash'),
('CreditCard','Payment via credit card'),
('PayPal','Online PayPal payment'),
('BankTransfer','Bank transfer'),
('ApplePay','Mobile payment'),
('VisaCard','Visa card'),
('MasterCard','MasterCard payment');

-- BOOKINGS
INSERT INTO Booking (GuestID, RoomID, DurationInNights, BookingDate, CancellationDeadline, CheckInDate, CheckOutDate, TotalPrice, PaymentStatus, NumberOfGuests, PaymentMethodID, SpecialRequests)
VALUES
(1,1,3,'2026-01-01','2026-01-02','2026-01-05','2026-01-08',300.00,'Paid',2,1,'Late check-in'),
(2,2,2,'2026-01-02','2026-01-03','2026-01-06','2026-01-08',240.00,'Paid',2,2,'Near elevator'),
(3,3,4,'2026-01-03','2026-01-04','2026-01-07','2026-01-11',600.00,'Pending',4,3,'Extra bed'),
(4,4,3,'2026-01-04','2026-01-05','2026-01-08','2026-01-11',540.00,'Paid',3,4,'None'),
(5,5,5,'2026-01-05','2026-01-06','2026-01-09','2026-01-14',1000.00,'Paid',6,5,'Sea view'),
(6,6,2,'2026-01-06','2026-01-07','2026-01-10','2026-01-12',420.00,'Paid',2,6,'Window view'),
(7,7,3,'2026-01-07','2026-01-08','2026-01-11','2026-01-14',390.00,'Paid',2,7,'Extra towels'),
(8,8,4,'2026-01-08','2026-01-09','2026-01-12','2026-01-16',640.00,'Paid',4,1,'High floor'),
(9,9,1,'2026-01-09','2026-01-10','2026-01-13','2026-01-14',145.00,'Paid',1,2,'None'),
(10,10,2,'2026-01-10','2026-01-11','2026-01-14','2026-01-16',440.00,'Pending',2,3,'Extra pillow'),
(11,11,3,'2026-01-11','2026-01-12','2026-01-15','2026-01-18',330.00,'Paid',2,4,'Near pool'),
(12,12,4,'2026-01-12','2026-01-13','2026-01-16','2026-01-20',680.00,'Paid',4,5,'Sea view'),
(13,13,5,'2026-01-13','2026-01-14','2026-01-17','2026-01-22',625.00,'Paid',3,6,'High floor'),
(14,14,2,'2026-01-14','2026-01-15','2026-01-18','2026-01-20',320.00,'Pending',2,7,'None'),
(15,15,3,'2026-01-15','2026-01-16','2026-01-19','2026-01-22',450.00,'Paid',3,1,'Extra bed'),
(16,16,4,'2026-01-16','2026-01-17','2026-01-20','2026-01-24',640.00,'Paid',4,2,'Sea view'),
(17,17,2,'2026-01-17','2026-01-18','2026-01-21','2026-01-23',270.00,'Pending',2,3,'None'),
(18,18,3,'2026-01-18','2026-01-19','2026-01-22','2026-01-25',510.00,'Paid',3,4,'Extra towels'),
(19,19,1,'2026-01-19','2026-01-20','2026-01-23','2026-01-24',145.00,'Paid',1,5,'Near elevator'),
(20,20,2,'2026-01-20','2026-01-21','2026-01-24','2026-01-26',500.00,'Paid',2,6,'High floor');


-- TRANSACTIONS
INSERT INTO Transactions (BookingID, GuestID, PaymentMethodID, Amount, TransactionType, Currency, Description)
VALUES
(1,1,1,300.00,'Payment','USD','Booking payment'),
(2,2,2,240.00,'Payment','USD','Booking payment'),
(3,3,3,600.00,'Payment','USD','Booking payment'),
(4,4,4,540.00,'Payment','USD','Booking payment'),
(5,5,5,1000.00,'Payment','USD','Booking payment'),
(6,6,6,420.00,'Payment','USD','Booking payment'),
(7,7,7,390.00,'Payment','USD','Booking payment'),
(8,8,1,640.00,'Payment','USD','Booking payment'),
(9,9,2,145.00,'Payment','USD','Booking payment'),
(10,10,3,440.00,'Payment','USD','Booking payment'),
(11,11,4,330.00,'Payment','USD','Booking payment'),
(12,12,5,680.00,'Payment','USD','Booking payment'),
(13,13,6,625.00,'Payment','USD','Booking payment'),
(14,14,7,320.00,'Payment','USD','Booking payment'),
(15,15,1,450.00,'Payment','USD','Booking payment'),
(16,16,2,640.00,'Payment','USD','Booking payment'),
(17,17,3,270.00,'Payment','USD','Booking payment'),
(18,18,4,510.00,'Payment','USD','Booking payment'),
(19,19,5,145.00,'Payment','USD','Booking payment'),
(20,20,6,500.00,'Payment','USD','Booking payment');


-- REVIEWS
INSERT INTO Review (BookingID, GuestID, VacationRentalID, Rating, ReviewDate, Comment, Response)
VALUES
(1,1,1,4.5,'2026-01-10','Very good','Thank you'),
(2,2,2,4.0,'2026-01-11','Nice location','Thanks'),
(3,3,3,4.8,'2026-01-12','Spacious house',''),
(4,4,4,4.2,'2026-01-13','Modern apartment',''),
(5,5,5,5.0,'2026-01-14','Excellent villa','Thanks'),
(6,6,6,4.3,'2026-01-15','Good',''),
(7,7,7,4.7,'2026-01-16','Clean and cozy',''),
(8,8,8,4.1,'2026-01-17','Nice view',''),
(9,9,9,3.9,'2026-01-18','Okay',''),
(10,10,10,4.6,'2026-01-19','Very comfortable',''),
(11,11,11,4.4,'2026-01-20','Great',''),
(12,12,12,4.5,'2026-01-21','Good host',''),
(13,13,13,4.8,'2026-01-22','Nice place',''),
(14,14,14,4.2,'2026-01-23','Lovely',''),
(15,15,15,4.9,'2026-01-24','Excellent',''),
(16,16,16,4.3,'2026-01-25','Clean',''),
(17,17,17,4.1,'2026-01-26','Comfortable',''),
(18,18,18,4.6,'2026-01-27','Nice stay',''),
(19,19,19,4.0,'2026-01-28','Good',''),
(20,20,20,4.7,'2026-01-29','Perfect','');


-- PROMOTIONS
INSERT INTO Promotion (VacationRentalID, DiscountPercentage, StartDate, EndDate, PromoCode, Description, MinNights)
VALUES
(1,10.0,'2026-01-01','2026-02-01','PROMO1','Winter discount',2),
(2,15.0,'2026-01-02','2026-02-02','PROMO2','New Year discount',3),
(3,5.0,'2026-01-03','2026-02-03','PROMO3','Special offer',1),
(4,20.0,'2026-01-04','2026-02-04','PROMO4','Limited time',4),
(5,12.5,'2026-01-05','2026-02-05','PROMO5','Holiday discount',2),
(6,8.0,'2026-01-06','2026-02-06','PROMO6','Early booking',3),
(7,10.0,'2026-01-07','2026-02-07','PROMO7','Special offer',1),
(8,15.0,'2026-01-08','2026-02-08','PROMO8','Limited time',4),
(9,5.0,'2026-01-09','2026-02-09','PROMO9','Discount',2),
(10,20.0,'2026-01-10','2026-02-10','PROMO10','Holiday offer',3),
(11,12.0,'2026-01-11','2026-02-11','PROMO11','Special discount',2),
(12,10.0,'2026-01-12','2026-02-12','PROMO12','Offer',1),
(13,15.0,'2026-01-13','2026-02-13','PROMO13','Winter sale',3),
(14,5.0,'2026-01-14','2026-02-14','PROMO14','Limited offer',2),
(15,20.0,'2026-01-15','2026-02-15','PROMO15','Special deal',3),
(16,10.0,'2026-01-16','2026-02-16','PROMO16','Discount',1),
(17,8.0,'2026-01-17','2026-02-17','PROMO17','Offer',2),
(18,12.0,'2026-01-18','2026-02-18','PROMO18','Holiday',3),
(19,15.0,'2026-01-19','2026-02-19','PROMO19','Winter',2),
(20,5.0,'2026-01-20','2026-02-20','PROMO20','Limited',1);


-- AMENITIES
INSERT INTO Amenity (AmenityName, Description)
VALUES
('WiFi','High-speed internet'),
('AirConditioning','Air conditioning system'),
('Pool','Swimming pool'),
('Parking','Private parking'),
('Kitchen','Full kitchen'),
('Heating','Heating system'),
('Washer','Washing machine'),
('Dryer','Dryer'),
('TV','Television'),
('Gym','Fitness room'),
('Fireplace','Fireplace'),
('Garden','Garden area'),
('Balcony','Balcony'),
('Terrace','Terrace'),
('HotTub','Hot tub'),
('CoffeeMachine','Coffee machine'),
('Dishwasher','Dishwasher'),
('Elevator','Elevator access'),
('Workspace','Workspace'),
('SoundSystem','Sound system');


-- VACATION RENTAL AMENITIES
INSERT INTO VacationRentalAmenity (VacationRentalID, AmenityID, IsAvailable)
VALUES
(1,1,TRUE),(1,2,TRUE),(1,3,TRUE),(1,4,TRUE),(1,5,TRUE),
(2,1,TRUE),(2,2,TRUE),(2,3,TRUE),(2,4,TRUE),(2,5,TRUE),
(3,1,TRUE),(3,2,TRUE),(3,3,TRUE),(3,4,TRUE),(3,5,TRUE),
(4,1,TRUE),(4,2,TRUE),(4,3,TRUE),(4,4,TRUE),(4,5,TRUE);


-- CANCELLATION POLICIES
INSERT INTO CancellationPolicy (PolicyName, RefundPercentage, Description)
VALUES
('Flexible',100.00,'Full refund up to 1 day before check-in'),
('Moderate',50.00,'50% refund up to 5 days before check-in'),
('Strict',25.00,'25% refund up to 7 days before check-in'),
('Non-Refundable',0.00,'No refund'),
('Super Flexible',100.00,'Full refund up to 3 days before check-in'),
('Moderate Plus',60.00,'60% refund up to 5 days before'),
('Flexible Plus',90.00,'90% refund up to 1 day before'),
('Strict Plus',30.00,'30% refund up to 7 days before'),
('Limited',40.00,'40% refund before check-in'),
('Partial',50.00,'50% refund before check-in'),
('Flexible Lite',80.00,'80% refund before check-in'),
('Moderate Lite',45.00,'45% refund before check-in'),
('Strict Lite',20.00,'20% refund before check-in'),
('Non Refund Lite',0.00,'No refund available'),
('Holiday',100.00,'Full refund 2 days before'),
('Winter',75.00,'75% refund 3 days before'),
('Summer',50.00,'50% refund 5 days before'),
('Spring',80.00,'80% refund 2 days before'),
('Autumn',60.00,'60% refund 4 days before'),
('Event',30.00,'30% refund 7 days before');


-- VACATION RENTAL POLICIES
INSERT INTO VacationRentalPolicy (VacationRentalID, PolicyID)
VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),
(6,6),(7,7),(8,8),(9,9),(10,10),
(11,11),(12,12),(13,13),(14,14),(15,15),
(16,16),(17,17),(18,18),(19,19),(20,20);


-- CUSTOMER SERVICE
INSERT INTO CustomerService (BookingID, GuestID, HostID, IssueDescription, IssueCategory, ReportDate, Resolution, ResolutionStatus, ContactMethod)
VALUES
(1,1,1,'Heater not working','Facility','2026-01-05','Fixed','Resolved','Email'),
(2,2,2,'WiFi issue','Facility','2026-01-06','Fixed','Resolved','Phone'),
(3,3,3,'Late check-in','Check-in','2026-01-07','Resolved','Resolved','Email'),
(4,4,4,'Extra towels','Request','2026-01-08','Provided','Resolved','Phone'),
(5,5,5,'Air conditioning issue','Facility','2026-01-09','Fixed','Resolved','Email'),
(6,6,6,'Noise complaint','Facility','2026-01-10','Addressed','Resolved','Phone'),
(7,7,7,'TV not working','Facility','2026-01-11','Fixed','Resolved','Email'),
(8,8,8,'Lost key','Check-in','2026-01-12','Replaced','Resolved','Phone'),
(9,9,9,'Billing issue','Payment','2026-01-13','Corrected','Resolved','Email'),
(10,10,10,'Late check-out','Check-out','2026-01-14','Approved','Resolved','Phone'),
(11,11,11,'Pool closed','Facility','2026-01-15','Refunded','Resolved','Email'),
(12,12,12,'Heating problem','Facility','2026-01-16','Fixed','Resolved','Phone'),
(13,13,13,'No hot water','Facility','2026-01-17','Fixed','Resolved','Email'),
(14,14,14,'Wrong room','Check-in','2026-01-18','Moved','Resolved','Phone'),
(15,15,15,'Cleaning issue','Facility','2026-01-19','Fixed','Resolved','Email'),
(16,16,16,'Booking cancellation','Booking','2026-01-20','Processed','Resolved','Phone'),
(17,17,17,'Damaged furniture','Facility','2026-01-21','Replaced','Resolved','Email'),
(18,18,18,'Noise complaint','Facility','2026-01-22','Addressed','Resolved','Phone'),
(19,19,19,'Lost item','Facility','2026-01-23','Returned','Resolved','Email'),
(20,20,20,'Extra bed request','Request','2026-01-24','Provided','Resolved','Phone');


-- EVENTS
INSERT INTO Event (VacationRentalID, HostID, EventName, Description, Capacity, StartDate, EndDate)
VALUES
(1,1,'Cooking Class','Learn to cook local dishes',10,'2026-01-05','2026-01-05'),
(2,2,'Yoga Session','Morning yoga',15,'2026-01-06','2026-01-06'),
(3,3,'Wine Tasting','Sample local wines',20,'2026-01-07','2026-01-07'),
(4,4,'Painting Workshop','Art class',12,'2026-01-08','2026-01-08'),
(5,5,'Dance Lesson','Learn local dances',18,'2026-01-09','2026-01-09'),
(6,6,'Meditation','Relaxation session',15,'2026-01-10','2026-01-10'),
(7,7,'Cooking Class','International cuisine',10,'2026-01-11','2026-01-11'),
(8,8,'Photography','Photo tour',12,'2026-01-12','2026-01-12'),
(9,9,'Music Jam','Live music',20,'2026-01-13','2026-01-13'),
(10,10,'Salsa Lesson','Dance workshop',15,'2026-01-14','2026-01-14'),
(11,11,'Yoga Session','Evening yoga',15,'2026-01-15','2026-01-15'),
(12,12,'Cooking Class','Italian cuisine',10,'2026-01-16','2026-01-16'),
(13,13,'Painting Workshop','Watercolors',12,'2026-01-17','2026-01-17'),
(14,14,'Wine Tasting','Red and white wines',20,'2026-01-18','2026-01-18'),
(15,15,'Meditation','Mindfulness',15,'2026-01-19','2026-01-19'),
(16,16,'Dance Lesson','Salsa',18,'2026-01-20','2026-01-20'),
(17,17,'Photography','Night shots',12,'2026-01-21','2026-01-21'),
(18,18,'Music Jam','Acoustic session',20,'2026-01-22','2026-01-22'),
(19,19,'Cooking Class','Desserts',10,'2026-01-23','2026-01-23'),
(20,20,'Yoga Session','Sunrise yoga',15,'2026-01-24','2026-01-24');


-- NOTIFICATIONS
INSERT INTO Notification (GuestID, HostID, Message, DateSent)
VALUES
(1,1,'Booking confirmed','2026-01-01'),
(2,2,'Booking confirmed','2026-01-02'),
(3,3,'Booking confirmed','2026-01-03'),
(4,4,'Booking confirmed','2026-01-04'),
(5,5,'Booking confirmed','2026-01-05'),
(6,6,'Booking confirmed','2026-01-06'),
(7,7,'Booking confirmed','2026-01-07'),
(8,8,'Booking confirmed','2026-01-08'),
(9,9,'Booking confirmed','2026-01-09'),
(10,10,'Booking confirmed','2026-01-10'),
(11,11,'Booking confirmed','2026-01-11'),
(12,12,'Booking confirmed','2026-01-12'),
(13,13,'Booking confirmed','2026-01-13'),
(14,14,'Booking confirmed','2026-01-14'),
(15,15,'Booking confirmed','2026-01-15'),
(16,16,'Booking confirmed','2026-01-16'),
(17,17,'Booking confirmed','2026-01-17'),
(18,18,'Booking confirmed','2026-01-18'),
(19,19,'Booking confirmed','2026-01-19'),
(20,20,'Booking confirmed','2026-01-20');


-- LOGIN HISTORY
INSERT INTO LoginHistory
(UserID, UserType, LoginDate, LogoutDate, LoginStatus)
VALUES
(1,'Guest','2026-01-01 09:00:00','2026-01-01 09:30:00','Success'),
(2,'Guest','2026-01-02 09:00:00','2026-01-02 09:30:00','Success'),
(3,'Guest','2026-01-03 09:00:00','2026-01-03 09:30:00','Success'),
(4,'Guest','2026-01-04 09:00:00','2026-01-04 09:30:00','Success'),
(5,'Guest','2026-01-05 09:00:00','2026-01-05 09:30:00','Success'),
(6,'Guest','2026-01-06 09:00:00','2026-01-06 09:30:00','Success'),
(7,'Guest','2026-01-07 09:00:00','2026-01-07 09:30:00','Success'),
(8,'Guest','2026-01-08 09:00:00','2026-01-08 09:30:00','Success'),
(9,'Guest','2026-01-09 09:00:00','2026-01-09 09:30:00','Success'),
(10,'Guest','2026-01-10 09:00:00','2026-01-10 09:30:00','Success'),
(11,'Guest','2026-01-11 09:00:00','2026-01-11 09:30:00','Success'),
(12,'Guest','2026-01-12 09:00:00','2026-01-12 09:30:00','Success'),
(13,'Guest','2026-01-13 09:00:00','2026-01-13 09:30:00','Success'),
(14,'Guest','2026-01-14 09:00:00','2026-01-14 09:30:00','Success'),
(15,'Guest','2026-01-15 09:00:00','2026-01-15 09:30:00','Success'),
(16,'Guest','2026-01-16 09:00:00','2026-01-16 09:30:00','Success'),
(17,'Guest','2026-01-17 09:00:00','2026-01-17 09:30:00','Success'),
(18,'Guest','2026-01-18 09:00:00','2026-01-18 09:30:00','Success'),
(19,'Guest','2026-01-19 09:00:00','2026-01-19 09:30:00','Success'),
(20,'Guest','2026-01-20 09:00:00','2026-01-20 09:30:00','Success'),

(21,'Host','2026-01-01 08:00:00','2026-01-01 12:00:00','Success'),
(22,'Host','2026-01-02 08:00:00','2026-01-02 12:00:00','Success'),
(23,'Host','2026-01-03 08:00:00','2026-01-03 12:00:00','Success'),
(24,'Host','2026-01-04 08:00:00','2026-01-04 12:00:00','Success'),
(25,'Host','2026-01-05 08:00:00','2026-01-05 12:00:00','Success'),
(26,'Host','2026-01-06 08:00:00','2026-01-06 12:00:00','Success'),
(27,'Host','2026-01-07 08:00:00','2026-01-07 12:00:00','Success'),
(28,'Host','2026-01-08 08:00:00','2026-01-08 12:00:00','Success'),
(29,'Host','2026-01-09 08:00:00','2026-01-09 12:00:00','Success'),
(30,'Host','2026-01-10 08:00:00','2026-01-10 12:00:00','Success'),
(31,'Host','2026-01-11 08:00:00','2026-01-11 12:00:00','Success'),
(32,'Host','2026-01-12 08:00:00','2026-01-12 12:00:00','Success'),
(33,'Host','2026-01-13 08:00:00','2026-01-13 12:00:00','Success'),
(34,'Host','2026-01-14 08:00:00','2026-01-14 12:00:00','Success'),
(35,'Host','2026-01-15 08:00:00','2026-01-15 12:00:00','Success'),
(36,'Host','2026-01-16 08:00:00','2026-01-16 12:00:00','Success'),
(37,'Host','2026-01-17 08:00:00','2026-01-17 12:00:00','Success'),
(38,'Host','2026-01-18 08:00:00','2026-01-18 12:00:00','Success'),
(39,'Host','2026-01-19 08:00:00','2026-01-19 12:00:00','Success'),
(40,'Host','2026-01-20 08:00:00','2026-01-20 12:00:00','Success');

-- SOCIAL NETWORKS
INSERT INTO SocialNetwork (NetworkName, NetworkURL)
VALUES
('Instagram','https://instagram.com'),('Facebook','https://facebook.com'),('Twitter','https://twitter.com'),
('LinkedIn','https://linkedin.com'),('Snapchat','https://snapchat.com'),('TikTok','https://tiktok.com'),
('Pinterest','https://pinterest.com'),('Reddit','https://reddit.com'),('YouTube','https://youtube.com'),
('WhatsApp','https://whatsapp.com'),('WeChat','https://wechat.com'),('Viber','https://viber.com'),
('Telegram','https://telegram.com'),('Discord','https://discord.com'),('Skype','https://skype.com'),
('Flickr','https://flickr.com'),('Tumblr','https://tumblr.com'),('Medium','https://medium.com'),
('Quora','https://quora.com'),('Twitch','https://twitch.tv');


-- GUEST SOCIAL NETWORKS
INSERT INTO GuestSocialNetwork (GuestID, SocialNetworkID, ProfileLink, Username, Verified)
VALUES
(1,1,'https://instagram.com/guest1','guest1',TRUE),
(2,2,'https://facebook.com/guest2','guest2',TRUE),
(3,3,'https://twitter.com/guest3','guest3',TRUE),
(4,4,'https://linkedin.com/guest4','guest4',FALSE),
(5,5,'https://snapchat.com/guest5','guest5',FALSE),
(6,6,'https://tiktok.com/guest6','guest6',TRUE),
(7,7,'https://pinterest.com/guest7','guest7',FALSE),
(8,8,'https://reddit.com/guest8','guest8',TRUE),
(9,9,'https://youtube.com/guest9','guest9',TRUE),
(10,10,'https://whatsapp.com/guest10','guest10',FALSE),
(11,11,'https://wechat.com/guest11','guest11',TRUE),
(12,12,'https://viber.com/guest12','guest12',FALSE),
(13,13,'https://telegram.com/guest13','guest13',TRUE),
(14,14,'https://discord.com/guest14','guest14',FALSE),
(15,15,'https://skype.com/guest15','guest15',TRUE),
(16,16,'https://flickr.com/guest16','guest16',FALSE),
(17,17,'https://tumblr.com/guest17','guest17',TRUE),
(18,18,'https://medium.com/guest18','guest18',FALSE),
(19,19,'https://quora.com/guest19','guest19',TRUE),
(20,20,'https://twitch.tv/guest20','guest20',TRUE);

-- Similar Rental
INSERT INTO SimilarRental (VacationRentalID, SimilarRentalID) VALUES
(1,2),
(1,3),
(2,4),
(2,5),
(3,6),
(3,7),
(4,8),
(4,9),
(5,10),
(5,11),
(6,12),
(6,13),
(7,14),
(7,15),
(8,16),
(9,17),
(10,18),
(11,19),
(12,20),
(13,1);


-- Tests
SELECT * FROM UserAccount;
SELECT * FROM Guest;
SELECT * FROM Host;
SELECT * FROM City;
SELECT * FROM Location;
SELECT * FROM VacationRental;
SELECT * FROM PaymentMethod;
SELECT * FROM Room;
SELECT * FROM Booking;
SELECT * FROM Review;
SELECT * FROM Transactions;
SELECT * FROM Promotion;
SELECT * FROM Amenity;
SELECT * FROM VacationRentalAmenity;
SELECT * FROM CancellationPolicy;
SELECT * FROM VacationRentalPolicy;
SELECT * FROM CustomerService;
SELECT * FROM Event;
SELECT * FROM Notification;
SELECT * FROM LoginHistory;
SELECT * FROM SocialNetwork;
SELECT * FROM GuestSocialNetwork;
SELECT * FROM SimilarRental;


-- 1. Retrieve guest names with booking info, room type, and total price
SELECT 
    ua.FullName,
    r.RoomType,
    b.BookingDate,
    b.CheckInDate,
    b.CheckOutDate,
    b.TotalPrice,
    b.PaymentStatus
FROM Booking b
JOIN Guest g ON b.GuestID = g.GuestID
JOIN UserAccount ua ON g.UserID = ua.UserID
JOIN Room r ON b.RoomID = r.RoomID
ORDER BY b.BookingDate DESC;


-- 2. Average Booking Price per City
SELECT 
    c.CityName,
    ROUND(AVG(b.TotalPrice), 2) AS AvgBookingPrice
FROM Booking b
JOIN Room r ON b.RoomID = r.RoomID
JOIN VacationRental vr ON r.VacationRentalID = vr.VacationRentalID
JOIN Location l ON vr.LocationID = l.LocationID
JOIN City c ON l.CityID = c.CityID
GROUP BY c.CityName
ORDER BY AvgBookingPrice DESC;


