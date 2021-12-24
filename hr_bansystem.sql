-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 16, 2021 at 10:29 PM
-- Server version: 10.4.19-MariaDB
-- PHP Version: 8.0.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `essentialmode`
--

-- --------------------------------------------------------

--
-- Table structure for table `hr_bansystem`
--
CREATE TABLE `hr_bansystem` (
	`ID` INT(11) NOT NULL AUTO_INCREMENT,
	`Steam` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`License` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`License2` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`IP` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`Discord` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`Xbox` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`Live` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`Tokens` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
	`Reason` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_bin',
	`isBanned` INT(11) NOT NULL DEFAULT '0',
	`Expire` INT(11) NOT NULL DEFAULT '0',
	INDEX `ID` (`ID`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=92
;


--
-- Indexes for dumped tables
--

--
-- Indexes for table `hr_bansystem`
--
ALTER TABLE `hr_bansystem`
  ADD KEY `ID` (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `hr_bansystem`
--
ALTER TABLE `hr_bansystem`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
