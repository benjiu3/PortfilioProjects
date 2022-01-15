/*

Cleaning data in SQL Queries

*/

select *
from [Portfolio Project].dbo.NashvilleHousing

-----------------------------------------------------

-- Standardize date format

select SaleDate, convert(date, saleDate)
from [Portfolio Project].dbo.NashvilleHousing

alter table NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)


-----------------------------------------------------

--Populate Property Address Data

select *
from [Portfolio Project].dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


----------------------------------------------------------

-- Breaking out address into individual columns (City, state, zip)

select PropertyAddress
from [Portfolio Project].dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from [Portfolio Project]..NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(PropertyAddress))

select * 
from [Portfolio Project]..NashvilleHousing

select OwnerAddress
from [Portfolio Project]..NashvilleHousing

select
 parsename(REPLACE(OwnerAddress, ',', '.'),3),
 parsename(REPLACE(OwnerAddress, ',', '.'),2),
 parsename(REPLACE(OwnerAddress, ',', '.'),1)
 from [Portfolio Project]..NashvilleHousing

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitAddress nvarchar(255);

  ALTER TABLE NashvilleHousing
 ADD OwnerSplitCity nvarchar(255);

  ALTER TABLE NashvilleHousing
 ADD OwnerSplitState nvarchar(255);

 Update NashvilleHousing
 set OwnerSplitAddress = parsename(REPLACE(OwnerAddress, ',', '.'),3)

  Update NashvilleHousing
 set OwnerSplitCity = parsename(REPLACE(OwnerAddress, ',', '.'),2)

  Update NashvilleHousing
 set OwnerSplitState = parsename(REPLACE(OwnerAddress, ',', '.'),1)

----------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant) as theCount
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [Portfolio Project]..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


----------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
select *,
ROW_NUMBER() over (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
from [Portfolio Project]..NashvilleHousing
--order by ParcelID
)
DELETE 
from RowNumCTE
where row_num > 1


---------------------------------------------------------------

--Delete unused columns

Select *
from [Portfolio Project]..NashvilleHousing

ALTER Table  [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table  [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate





