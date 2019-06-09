-- MySQL dump 10.13  Distrib 5.7.25, for Linux (x86_64)
--
-- Host: localhost    Database: mydb
-- ------------------------------------------------------
-- Server version	5.7.25-log

SET GLOBAL wait_timeout=600;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

--
-- Table structure for table `Company`
--

DROP TABLE IF EXISTS `Company`;
CREATE TABLE `Company` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `email` varchar(45) NOT NULL,
  `password` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Company`
--

LOCK TABLES `Company` WRITE;
INSERT INTO `Company` VALUES (1,'SFSU','SFSU','password');
UNLOCK TABLES;

--
-- Table structure for table `Controls`
--

DROP TABLE IF EXISTS `Controls`;
CREATE TABLE `Controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `report_id` int(11) NOT NULL,
  `time_card_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`employee_id`,`report_id`,`time_card_id`,`company_id`),
  KEY `report_id_idx` (`report_id`),
  KEY `time_card_id_idx` (`time_card_id`),
  KEY `cid_idx` (`company_id`),
  KEY `eid_idx` (`employee_id`),
  CONSTRAINT `cid` FOREIGN KEY (`company_id`) REFERENCES `Login` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `empid` FOREIGN KEY (`employee_id`) REFERENCES `Employee` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `repid` FOREIGN KEY (`report_id`) REFERENCES `Report` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `tcid` FOREIGN KEY (`time_card_id`) REFERENCES `Time_Card` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Controls`
--

LOCK TABLES `Controls` WRITE;

UNLOCK TABLES;

--
-- Table structure for table `Employee`
--

DROP TABLE IF EXISTS `Employee`;
CREATE TABLE `Employee` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `pin` int(11) NOT NULL unique,
  `wage` float NOT NULL,
  `company_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`wage`,`pin`,`name`),
  KEY `FK_employee_1` (`company_id`),
  CONSTRAINT `FK_employee_1` FOREIGN KEY (`company_id`) REFERENCES `Company` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Employee`
--

LOCK TABLES `Employee` WRITE;
INSERT INTO `Employee` VALUES (1,'Eddy',1234,12,1);
UNLOCK TABLES;

--
-- Table structure for table `Includes`
--

DROP TABLE IF EXISTS `Includes`;
CREATE TABLE `Includes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time_card_id` int(11) NOT NULL,
  `report_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`,`time_card_id`),
  KEY `time_card_id_idx` (`time_card_id`),
  KEY `report_id_idx` (`report_id`),
  CONSTRAINT `report_id` FOREIGN KEY (`report_id`) REFERENCES `Report` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `time_card_id` FOREIGN KEY (`time_card_id`) REFERENCES `Time_Card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Includes`
--

LOCK TABLES `Includes` WRITE;
UNLOCK TABLES;

--
-- Table structure for table `Login`
--

DROP TABLE IF EXISTS `Login`;
CREATE TABLE `Login` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expiration` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `session_key` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id_idx` (`company_id`),
  CONSTRAINT `company_id` FOREIGN KEY (`company_id`) REFERENCES `Company` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Login`
--

LOCK TABLES `Login` WRITE;
UNLOCK TABLES;

--
-- Table structure for table `Paycheck`
--

DROP TABLE IF EXISTS `Paycheck`;
CREATE TABLE `Paycheck` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `amount` FLOAT NOT NULL,
  `employee_wage` FLOAT NULL,
  `report_hours_worked` FLOAT NULL,
  `employee_id` INT NULL,
  `report_id` INT NULL,
  PRIMARY KEY (`id`),
  INDEX `eid_idx` (`employee_id` ASC) ,
  CONSTRAINT `eid`
    FOREIGN KEY (`employee_id`)
    REFERENCES `mydb`.`Employee` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `rid`
    FOREIGN KEY (`id`)
    REFERENCES `mydb`.`Report` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Paycheck`
--

LOCK TABLES `Paycheck` WRITE;

UNLOCK TABLES;

--
-- Table structure for table `Report`
--

DROP TABLE IF EXISTS `Report`;

CREATE TABLE `Report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `hours_worked` float NOT NULL,
  `employee_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  PRIMARY KEY (`id`,`hours_worked`),
  KEY `fk_Report_1` (`employee_id`),
  CONSTRAINT `fk_Report_1` FOREIGN KEY (`employee_id`) REFERENCES `Employee` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Report`
--

LOCK TABLES `Report` WRITE;
UNLOCK TABLES;

--
-- Table structure for table `Time_Card`
--

DROP TABLE IF EXISTS `Time_Card`;

CREATE TABLE `Time_Card` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time_in` time NOT NULL,
  `time_out` time NOT NULL,
  `employee_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `company_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `employee_id_idx` (`employee_id`),
  CONSTRAINT `employee_id` FOREIGN KEY (`employee_id`) REFERENCES `Employee` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Time_Card`
--

LOCK TABLES `Time_Card` WRITE;
INSERT INTO `Time_Card` VALUES (1,'10:00:00','15:00:00',1,'2019-05-16',1),(2,'11:00:00','13:00:00',1,'2019-05-17',1);
UNLOCK TABLES;
/

-- Dump completed on 2019-05-19  1:45:10
