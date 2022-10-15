-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `db` DEFAULT CHARACTER SET utf8 ;
USE `db` ;

-- -----------------------------------------------------
-- Table `db`.`components`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db`.`components` (
  `componentId` INT(6) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(32) NOT NULL,
  `type` INT(1) UNSIGNED NOT NULL,
  `description` VARCHAR(8196) NOT NULL,
  `cost` INT(6) UNSIGNED NOT NULL,
  `image` BLOB NULL,
  `count` INT(6) UNSIGNED NOT NULL,
  PRIMARY KEY (`componentId`),
  UNIQUE INDEX `componentId_UNIQUE` (`componentId` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db`.`clients`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db`.`clients` (
  `clientId` INT(6) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(16) NOT NULL,
  `surname` VARCHAR(45) NOT NULL,
  `phone` INT(11) UNSIGNED NOT NULL,
  `address` VARCHAR(256) NOT NULL,
  `email` VARCHAR(32) NOT NULL,
  `password` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`clientId`),
  UNIQUE INDEX `phone_UNIQUE` (`phone` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `db`.`employeeInfo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db`.`employeeInfo` (
  `employeeId` INT(6) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(16) NOT NULL,
  `surname` VARCHAR(16) NOT NULL,
  `phone` INT(11) UNSIGNED NOT NULL,
  `email` VARCHAR(32) NOT NULL,
  `salary` INT(4) UNSIGNED NOT NULL,
  `jobType` INT(1) UNSIGNED NOT NULL,
  PRIMARY KEY (`employeeId`),
  UNIQUE INDEX `employeeId_UNIQUE` (`employeeId` ASC) VISIBLE,
  UNIQUE INDEX `phone_UNIQUE` (`phone` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db`.`managers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db`.`managers` (
  `employeeId` INT(6) UNSIGNED NOT NULL,
  PRIMARY KEY (`employeeId`),
  UNIQUE INDEX `employeeId_UNIQUE` (`employeeId` ASC) VISIBLE,
  CONSTRAINT `employeeIdFM`
    FOREIGN KEY (`employeeId`)
    REFERENCES `db`.`employeeInfo` (`employeeId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db`.`deliveryWorkers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db`.`deliveryWorkers` (
  `employeeId` INT(6) UNSIGNED NOT NULL,
  PRIMARY KEY (`employeeId`),
  UNIQUE INDEX `employeeId_UNIQUE` (`employeeId` ASC) VISIBLE,
  CONSTRAINT `employeeIdFDW`
    FOREIGN KEY (`employeeId`)
    REFERENCES `db`.`employeeInfo` (`employeeId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db`.`orders` (
  `orderId` INT(6) UNSIGNED NOT NULL AUTO_INCREMENT,
  `clientId` INT(6) UNSIGNED NOT NULL,
  `managerId` INT(6) UNSIGNED NULL,
  `deliveryWorkerId` INT(6) UNSIGNED NULL,
  `cost` INT(6) UNSIGNED NOT NULL,
  `count` INT(3) UNSIGNED NOT NULL,
  `creationDatetime` INT(10) UNSIGNED NOT NULL,
  `completionDatetime` INT(10) UNSIGNED NULL,
  PRIMARY KEY (`orderId`, `clientId`),
  INDEX `clientId_idx` (`clientId` ASC) VISIBLE,
  INDEX `managerId_idx` (`managerId` ASC) VISIBLE,
  INDEX `deliveryWorkerId_idx` (`deliveryWorkerId` ASC) VISIBLE,
  CONSTRAINT `clientIdFO`
    FOREIGN KEY (`clientId`)
    REFERENCES `db`.`clients` (`clientId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `managerIdFO`
    FOREIGN KEY (`managerId`)
    REFERENCES `db`.`managers` (`employeeId`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `deliveryWorkerIdFO`
    FOREIGN KEY (`deliveryWorkerId`)
    REFERENCES `db`.`deliveryWorkers` (`employeeId`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `db`.`boughtComponents`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db`.`boughtComponents` (
  `componentId` INT(6) UNSIGNED NOT NULL,
  `orderId` INT(6) UNSIGNED NOT NULL,
  `clientId` INT(6) UNSIGNED NOT NULL,
  PRIMARY KEY (`componentId`, `orderId`, `clientId`),
  INDEX `orderId_idx` (`orderId` ASC) VISIBLE,
  INDEX `clientId_idx` (`clientId` ASC) VISIBLE,
  CONSTRAINT `componentIdFB`
    FOREIGN KEY (`componentId`)
    REFERENCES `db`.`components` (`componentId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `orderIdFB`
    FOREIGN KEY (`orderId`)
    REFERENCES `db`.`orders` (`orderId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `clientIdFB`
    FOREIGN KEY (`clientId`)
    REFERENCES `db`.`clients` (`clientId`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
USE `db`;

DELIMITER $$
USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`components_AFTER_DELETE` AFTER DELETE ON `components` FOR EACH ROW
BEGIN
	DELETE FROM boughtComponents WHERE boughtComponents.componentId = OLD.componentId;
END$$

USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`clients_AFTER_DELETE` AFTER DELETE ON `clients` FOR EACH ROW
BEGIN
	DELETE FROM orders WHERE orders.clientId = OLD.clientId;
END$$

USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`managers_AFTER_DELETE` AFTER DELETE ON `managers` FOR EACH ROW
BEGIN
	DELETE FROM employeeInfo WHERE employeeInfo.employeeId = OLD.employeeId;
END$$

USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`managers_AFTER_INSERT` AFTER INSERT ON `managers` FOR EACH ROW
BEGIN
	update employeeInfo set jobType = 0 where employeeId = NEW.employeeId;
END$$

USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`deliveryWorkers_AFTER_DELETE` AFTER DELETE ON `deliveryWorkers` FOR EACH ROW
BEGIN
	DELETE FROM employeeInfo WHERE employeeInfo.employeeId = OLD.employeeId;
END$$

USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`deliveryWorkers_AFTER_INSERT` AFTER INSERT ON `deliveryWorkers` FOR EACH ROW
BEGIN
	update employeeInfo set jobType = 1 where employeeId = NEW.employeeId;
END$$

USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`orders_AFTER_DELETE` AFTER DELETE ON `orders` FOR EACH ROW
BEGIN
	DELETE FROM boughtComponents WHERE boughtComponents.clientId = OLD.clientId AND boughtComponents.orderId = OLD.orderId;
END$$

USE `db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `db`.`boughtComponents_AFTER_INSERT` AFTER INSERT ON `boughtComponents` FOR EACH ROW
BEGIN
	update components set count = count - 1 where components.componentId = NEW.componentId;
END$$


DELIMITER ;
