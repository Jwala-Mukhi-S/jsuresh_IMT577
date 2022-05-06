/*****************************************
Course: IMT 577
Instructor: Sean Pettersen
Assignment: Module 6
Date: 05/08/2021
Notes: Create dimension Channel
*****************************************/

--===================================================
-------------DIM_CHANNEL
--==================================================

--CREATE CHANNEL TABLE
CREATE OR REPLACE TABLE IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Channel(
    DimChannelID INT IDENTITY(1,1) CONSTRAINT PK_DimChannelID PRIMARY KEY NOT NULL,--Surrogate Key
	ChannelID INTEGER NOT NULL, --Natural Key
    ChannelCategoryID INTEGER NOT NULL,
    ChannelName VARCHAR(255) NOT NULL,
    ChannelCategory VARCHAR(255) NOT NULL,
);

--Load unknown members
INSERT INTO Dim_Channel
(
   DimChannelID
   ChannelID,
   ChannelCategoryID,
   ChannelName,
   ChannelCategory,
)
VALUES
( 
    -1
    -1,
    -1,
    'Unknown',
    'Unknown',
);

--Load values from stage tables into the dimension table
INSERT INTO Dim_Channel
(
    ChannelID
    ChannelCategoryID,
    ChannelName,
    ChannelCategory,
)
SELECT 
    ChannelID,
    s.ChannelCategoryID,
    Channel AS ChannelName,
    ChannelCategory
	FROM STAGE_CHANNEL s JOIN STAGE_CHANNELCATEGORY c
    on s.ChannelCategoryID = c.ChannelCategoryID;

--===================================================
-------------DIM_PRODUCT
--==================================================

CREATE OR REPLACE TABLE IMT577_DW_JWALA_SURESH.PUBLIC.

--===================================================
-------------DIM_LOCATION
--==================================================

--CREATE LOCATION TABLE
CREATE OR REPLACE TABLE IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Location(
    DimLocationID INT IDENTITY(1,1) CONSTRAINT PK_DimLocationID PRIMARY KEY NOT NULL --Surrogate Key
    ,PostalCode VARCHAR(255) NOT NULL --Natural Key
    ,Address VARCHAR(255) NOT NULL
    ,City VARCHAR(255) NOT NULL
    ,StateProvince VARCHAR(255) NOT NULL
    ,Country VARCHAR(255) NOT NULL
);

--Load unknown members
INSERT INTO Dim_Location
(
    DimLocationID
    ,PostalCode
    ,Address
    ,City
    ,StateProvince
    ,Country
)
VALUES
( 
    -1
    ,-1
    ,'Unknown' 
    ,'Unknown' 
    ,'Unknown'
    ,'Unknown' 
);

--Load values from stage tables into the dimension table
INSERT INTO Dim_Location
(
    PostalCode
    ,Address
    ,City
    ,StateProvince
    ,Country
)
SELECT
    PostalCode
    ,Address
    ,City
    ,StateProvince
    ,Country
FROM STAGE_STORE UNION 
SELECT
    PostalCode
    ,Address
    ,City
    ,StateProvince
    ,Country
FROM STAGE_RESELLER UNION
SELECT
    PostalCode
    ,Address
    ,City
    ,StateProvince
    ,Country
FROM STAGE_CUSTOMER;

--===================================================
-------------DIM_STORE
--==================================================

--CREATE STORE TABLE
CREATE OR REPLACE TABLE IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Store(
    DimStoreID INT IDENTITY(1,1) CONSTRAINT PK_DimStoreID PRIMARY KEY NOT NULL --Surrogate Key
    ,DimLocationID INTEGER CONSTRAINT FK_DimLocationIDStore FOREIGN KEY REFERENCES IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Location (DimLocationID) NOT NULL --Foreign Key
    ,StoreID INTEGER NOT NULL--Natural Key
    ,StoreNumber INTEGER NOT NULL
    ,StoreManager VARCHAR(255) NOT NULL 
    ,PhoneNumber VARCHAR(255) NOT NULL
);

--Load unknown members
INSERT INTO Dim_Store
(
    DimStoreID
    ,DimLocationID
    ,StoreID
    ,StoreNumber
    ,StoreManager
    ,PhoneNumber
)
VALUES
( 
    -1
    ,-1
    ,-1
    ,-1
    ,'Unknown' 
    ,'Unknown'
);

--Load values from stage tables into the dimension table
INSERT INTO Dim_Store
(
    DimLocationID
    ,StoreID
    ,StoreNumber
    ,StoreManager
    ,PhoneNumber
)
SELECT
    DimLocationID
    ,StoreID
    ,StoreNumber
    ,StoreManager
    ,PhoneNumber
FROM Dim_Location d join STAGE_STORE s
WHERE
d.PostalCode = s.PostalCode AND d.Address = s.Address ;

--===================================================
-------------DIM_RESELLER
--==================================================

--CREATE RESELLER TABLE
CREATE OR REPLACE TABLE IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Reseller(
    DimResellerID INT IDENTITY(1,1) CONSTRAINT PK_DimResellerID PRIMARY KEY NOT NULL --Surrogate Key
    ,DimLocationID INTEGER CONSTRAINT FK_DimLocationIDReseller FOREIGN KEY REFERENCES IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Location (DimLocationID) NOT NULL --Foreign Key
    ,ResellerID  VARCHAR(255) NOT NULL--Natural Key
    ,ResellerName VARCHAR(255) NOT NULL
    ,ContactName VARCHAR(255) NOT NULL
    ,PhoneNumber VARCHAR(255) NOT NULL
    ,Email VARCHAR(255) NOT NULL
);

--Load unknown members
INSERT INTO Dim_Reseller
(
    DimResellerID
    ,DimLocationID
    ,ResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email
)
VALUES
( 
    -1
    ,-1
    ,-1
    ,'Unknown'
    ,'Unknown' 
    ,'Unknown'
    ,'Unknown'
);

--Load values from stage tables into the dimension table
INSERT INTO Dim_Reseller
(
    DimLocationID
    ,ResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email
)
SELECT
    DimLocationID
    ,ResellerID
    ,ResellerName
    ,Contact AS ContactName
    ,PhoneNumber
    ,EmailAddress AS Email
FROM Dim_Location d join STAGE_RESELLER r
WHERE
d.PostalCode = r.PostalCode AND d.Address = r.Address ;

--===================================================
-------------DIM_CUSTOMER
--==================================================

--CREATE CUSTOMER TABLE
CREATE OR REPLACE TABLE IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Customer(
    DimCustomerID INT IDENTITY(1,1) CONSTRAINT PK_DimCustomerID PRIMARY KEY NOT NULL, --Surrogate Key
    DimLocationID INTEGER CONSTRAINT FK_DimLocationIDCustomer FOREIGN KEY REFERENCES IMT577_DW_JWALA_SURESH.PUBLIC.Dim_Location (DimLocationID) NOT NULL, --Foreign Key
    CustomerID VARCHAR(255) NOT NULL, --Natural Key
    FullName VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Gender VARCHAR(255) NOT NULL,
    EmailAddress VARCHAR(255) NOT NULL,
    PhoneNumber  VARCHAR(255) NOT NULL
);

--Load unknown members
INSERT INTO Dim_Customer
(
    DimCustomerID,
    DimLocationID,
    CustomerID,
    FullName,
    FirstName,
    LastName,
    Gender,
    EmailAddress,
    PhoneNumber
)
VALUES
( 
    -1,
    -1,
    -1,
    'Unknown', 
    'Unknown', 
    'Unknown',
    'Unknown', 
    'Unknown',
    'Unknown'
);

--Load values from stage tables into the dimension table
INSERT INTO Dim_Customer
(
    DimLocationID,
    CustomerID,
    FullName,
    FirstName,
    LastName,
    Gender,
    EmailAddress,
    PhoneNumber
)
SELECT
    DimLocationID
    ,CustomerID
    ,concat(FirstName,' ',LastName) AS FullName
    ,FirstName
    ,LastName
    ,Gender
    ,EmailAddress
    ,PhoneNumber
FROM Dim_Location d join STAGE_CUSTOMER c
WHERE
d.PostalCode = c.PostalCode AND d.Address = c.Address ;
