/* Cleaning data in SQL queries 

- Standardize date format, update Saledate column by removing timestamp
- Split address information into address, city and state using SUBSTRING and PARSENAME function
- Remove duplicates using ROW_NUMBER(), CTE
- Delete unused columns
*/

Select * from PortfolioProject..NashvilleHousing

-- Standardize date format

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(date,saledate)

--OR 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(date,saledate)

-- Populate Property Address Data

Select na.ParcelID, na.PropertyAddress, nas.ParcelID, nas.PropertyAddress, ISNULL(na.PropertyAddress,nas.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing na
JOIN PortfolioProject.dbo.NashvilleHousing nas
	on na.ParcelID = nas.ParcelID
	AND na.[UniqueID ] <> nas.[UniqueID ]
Where na.PropertyAddress is null

Update na
Set na.PropertyAddress = ISNULL(na.PropertyAddress, nas.PropertyAddress)
from PortfolioProject..NashvilleHousing na
Join PortfolioProject..NashvilleHousing nas
On na.ParcelID = nas.ParcelID
And na.[UniqueID ] <> nas.[UniqueID ]
where na.PropertyAddress is null

-- Breaking down Address into Individual columns (Address, City, State)
/* Property Address*/

Select
Substring(PropertyAddress,1,Charindex(',',PropertyAddress) -1) as Address
From PortfolioProject..NashvilleHousing        

Select
Substring(PropertyAddress,Charindex(',',PropertyAddress) + 1, len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing   

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(250)

UPDATE NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress,1,Charindex(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(250)

UPDATE NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress,Charindex(',',PropertyAddress) + 1, len(PropertyAddress))

/* Owner's Address*/

Select
parsename(Replace(OwnerAddress,',','.'),3) as OwnerAddress,
parsename(Replace(OwnerAddress,',','.'),2) as OwnerCity,
parsename(Replace(OwnerAddress,',','.'),1) as OwnerState
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(250)

UPDATE NashvilleHousing
Set OwnerSplitAddress = parsename(Replace(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(250)

UPDATE NashvilleHousing
Set OwnerSplitCity = parsename(Replace(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(250)

UPDATE NashvilleHousing
Set OwnerSplitState = parsename(Replace(OwnerAddress,',','.'),1)


-- Change Y and N in "Sold as Vacant" field
/* Check available values at SoldAsVacant column, and decide how to replace values */

Select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select Case SoldAsVacant
When 'Y' then 'Yes'
When 'N' then 'No'
Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = Case SoldAsVacant
When 'Y' then 'Yes'
When 'N' then 'No'
Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

-- Remove duplicates

With RowNumCTE As (Select *,ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID) 
			row_num
From PortfolioProject..NashvilleHousing)
DELETE From RowNumCTE 
Where row_num > 1


 -- Delete unused columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress 
 
Select * From PortfolioProject..NashvilleHousing