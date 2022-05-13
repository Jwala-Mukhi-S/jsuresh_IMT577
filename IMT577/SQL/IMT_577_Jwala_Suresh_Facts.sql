/*****************************************
Course: IMT 577B
Instructor: Sean Pettersen
Assignment: Module 7
Date: 05/15/2021
Notes: Create fact tables
*****************************************/

--===================================================
-------------FACT_SALESACTUAL
--==================================================

--Create fact table
CREATE OR REPLACE TABLE FACT_SALESACTUAL(
    DimProductID INT CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductId) NOT NULL
    ,DimStoreID INT CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreId) NOT NULL
    ,DimResellerID INT CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerId) NOT NULL
    ,DimCustomerID INT CONSTRAINT FK_DimCustomerID FOREIGN KEY REFERENCES Dim_Customer(DimCustomerId) NOT NULL
    ,DimChannelID INT CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelId) NOT NULL
    ,DimSaleDateID NUMBER(9,0) CONSTRAINT FK_DimSaleDateID FOREIGN KEY REFERENCES Dim_Date(DATE_PKEY) NOT NULL
    ,DimLocationID INT CONSTRAINT FK_DimLocationID FOREIGN KEY REFERENCES Dim_Location(DimLocationID) NOT NULL
    ,SalesHeaderID INTEGER
    ,SalesDetailID INTEGER
    ,SalesAmount FLOAT
	,SalesQuantity INTEGER
	,SaleUnitPrice FLOAT
	,SaleExtendedCost FLOAT
	,SaleTotalProfit FLOAT
);
									
--- Load values into fact table
INSERT INTO FACT_SALESACTUAL
(
	DimProductID
   	,DimStoreID
    ,DimResellerID
    ,DimCustomerID
    ,DimChannelID
    ,DimSaleDateID
	,DimLocationID
    ,SalesHeaderID
    ,SalesDetailID
    ,SalesAmount
	,SalesQuantity
	,SaleUnitPrice
	,SaleExtendedCost
	,SaleTotalProfit
)
SELECT DISTINCT
    NVL(DimProductID,-1) AS DimProductID
    ,NVL(DimStoreID,-1) AS DimStoreID
   	,NVL(DimResellerID,-1) AS DimResellerID
	,NVL(DimCustomerID,-1) AS DimCustomerID
    ,NVL(DimChannelID,-1) AS DimChannelID
    ,DATE_PKEY AS DimSaleDateID
	,NVL(l.DimLocationID,-1) AS DimLocationID
	,NVL(sh.SalesHeaderID,-1) AS SalesHeaderID
	,NVL(SalesDetailID,-1) AS SalesDetailID
	,SalesAmount
	,SalesQuantity
    ,(SalesAmount/SalesQuantity) AS SaleUnitPrice
    ,(ProductCost*SalesQuantity) AS SaleExtendedCost
    ,((SaleUnitPrice-ProductCost) * SalesQuantity) AS SaleTotalProfit
FROM Stage_SalesHeader sh
JOIN Stage_SalesDetail sd
ON sh.SalesHeaderID = sd.SalesHeaderID
LEFT OUTER JOIN Dim_Product p
ON sd.ProductID = p.ProductID
LEFT OUTER JOIN Dim_Store s
ON sh.StoreID = s.StoreID
LEFT OUTER JOIN Dim_Reseller r
ON sh.ResellerID = r.ResellerID
LEFT OUTER JOIN Dim_Customer c
ON sh.CustomerID = c.CustomerID
LEFT OUTER JOIN Dim_Channel ch
ON sh.ChannelID = ch.ChannelID
LEFT OUTER JOIN Dim_Date d
ON d.Date = to_date(sh.date,'MM/DD/YY')
LEFT OUTER JOIN Dim_Location l
ON l.DimLocationID = s.DimLocationID OR  l.DimLocationID = r.DimLocationID OR
l.DimLocationID = c.DimLocationID;

--View Table
SELECT * FROM FACT_SALESACTUAL;

--===================================================
-------------FACT_SRCSALESTARGET
--==================================================

--Create fact table
CREATE OR REPLACE TABLE FACT_SRCSALESTARGET(
    DimStoreID INT CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID) NOT NULL
    ,DimResellerID INT CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerId) NOT NULL
    ,DimChannelID INT CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelId) NOT NULL
    ,DimTargetDateID NUMBER(9,0) CONSTRAINT FK_DimTargetDateID FOREIGN KEY REFERENCES Dim_Date(DATE_PKEY) NOT NULL
    ,SalesTargetAmount FLOAT
);

--- Load values into fact table
INSERT INTO FACT_SRCSALESTARGET
(
    DimStoreID
    ,DimResellerID
    ,DimChannelID
    ,DimTargetDateID
    ,SalesTargetAmount
)
SELECT DISTINCT
    NVL(DimStoreID,-1) AS DimStoreID
    ,NVL(DimResellerID,-1) AS DimResellerID
    ,NVL(DimChannelID,-1) AS DimChannelID
    ,DATE_PKEY AS DimTargetDateID
    ,(TargetSalesAmount/365) AS SalesTargetAmount
FROM STAGE_TARGETDATACHANNELRESELLERANDSTORE st
INNER JOIN Dim_Channel c 
ON c.ChannelName = 
CASE
WHEN st.ChannelName = 'Online' then 'On-line'
ELSE st.ChannelName
END
LEFT OUTER JOIN Dim_Reseller r
ON  st.TargetName = 
CASE
WHEN r.ResellerName = 'Mississipi Distributors' then 'Mississippi Distributors'
ELSE r.ResellerName
END
LEFT OUTER JOIN Dim_Date d
ON d.YEAR = st.YEAR
LEFT OUTER JOIN Dim_Store s
ON s.StoreNumber = 
CASE
WHEN st.TargetName = 'Store Number 5' then 5
WHEN st.TargetName = 'Store Number 8' then 8
WHEN st.TargetName = 'Store Number 10' then 10
WHEN st.TargetName = 'Store Number 21' then 21
WHEN st.TargetName = 'Store Number 34' then 34
WHEN st.TargetName = 'Store Number 39' then 39
ELSE -1
END;

--View Table
SELECT * FROM FACT_SRCSALESTARGET;

--===================================================
-------------FACT_PRODUCTSALESTARGET
--==================================================

--Create fact table
CREATE OR REPLACE TABLE FACT_PRODUCTSALESTARGET(
    DimProductID INT CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductId) NOT NULL
    ,DimTargetDateID NUMBER(9,0) CONSTRAINT FK_DimTargetDateID FOREIGN KEY REFERENCES Dim_Date(DATE_PKEY) NOT NULL
    ,ProductTargetSalesQuantity FLOAT
);

--- Load values into fact table
INSERT INTO FACT_PRODUCTSALESTARGET
(
    DimProductID
   	,DimTargetDateID
    ,ProductTargetSalesQuantity
)
SELECT DISTINCT
	NVL(DimProductID,-1) AS DimProductID
    ,DATE_PKEY AS DimTargetDateID
	,(SalesQuantityTarget/365) AS ProductTargetSalesQuantity
FROM STAGE_TARGETDATAPRODUCT sp
LEFT OUTER JOIN Dim_Product dp
ON sp.ProductID = dp.ProductID
LEFT OUTER JOIN Dim_Date d
ON d.YEAR = sp.YEAR;	

--View Table
SELECT * FROM FACT_PRODUCTSALESTARGET;