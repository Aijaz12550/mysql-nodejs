/*
SQLyog Community v13.1.5  (64 bit)
MySQL - 8.0.17 : Database - playdate
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`playdate` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `playdate`;

/* Procedure structure for procedure `addCardDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `addCardDetails` */;

DELIMITER $$

 CREATE DEFINER=`webuser`@`%` PROCEDURE `addCardDetails`(IN pId INT, IN nCard VARCHAR(255), IN cId VARCHAR(255), IN cBrnd VARCHAR(255), IN cType VARCHAR(255), IN cNum VARCHAR(255), IN isPrim TINYINT(2))
BEGIN
	SELECT COUNT(*) INTO @co FROM cardDetails WHERE parentId = pId AND isPrimsry = 1 LIMIT 1;
	IF @co = 0 THEN
	INSERT INTO carddetails (parentId, nameOnCard, cardId, cardBrand, cardType, cardNumber, isPrimary) VALUES (pId,nCard,cId,cBrnd,cType,cNum,'1');
	ELSE
	INSERT INTO carddetails (parentId, nameOnCard, cardId, cardBrand, cardType, cardNumber, isPrimary) VALUES (pId,nCard,cId,cBrnd,cType,cNum,isPrim);
	END IF;
	SET @cId = LAST_INSERT_ID();
	IF isPrim = 1 THEN
	UPDATE `carddetails` SET isPrimary = '0' WHERE parentId = pId AND cardId != cId AND isPrimary = 1;
	END IF;
	SELECT @cId AS cardId, @co AS cardExist;
END 
DELIMITER ;

/* Procedure structure for procedure `addChildToParent` */

/*!50003 DROP PROCEDURE IF EXISTS  `addChildToParent` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `addChildToParent`(IN pid INT, IN fname TEXT , IN lname TEXT, IN pimage TEXT, IN smallpimage TEXT, IN isEna TINYINT(2), IN viewParId VARCHAR(255), IN coViewParId VARCHAR(255))
BEGIN
	INSERT INTO childrens (parentId, firstName, lastName, profileImage, smallProfileImage, viewParentId, coViewParentId, isEnabled) VALUES (pid, fname, lname, pimage, smallpimage, viewParId, coViewParId, isEna);
	SELECT * FROM childrens WHERE parentId = pid AND childId IN (SELECT LAST_INSERT_ID());
END */$$
DELIMITER ;

/* Procedure structure for procedure `blockMyContact` */

/*!50003 DROP PROCEDURE IF EXISTS  `blockMyContact` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `blockMyContact`(IN myUserId INT, IN blockUserId INT)
BEGIN
	SELECT COUNT(*) INTO @co FROM `blockedusers` WHERE blockedBy = myUserId AND blockedUserId = blockUserId;
	IF @co = 0 THEN
	     INSERT INTO `blockedusers` (blockedBy, blockedUserId) VALUES (myUserId, blockUserId);
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `CheckInviteeBlockStatus` */

/*!50003 DROP PROCEDURE IF EXISTS  `CheckInviteeBlockStatus` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `CheckInviteeBlockStatus`(IN myUserId INT, IN blockUserId INT)
BEGIN
	SET @isRes = 1;
	SET @isPar = 0;
	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @coIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, myUserId) AND STATUS = 'accepted' AND NOT FIND_IN_SET(coParentId, myUserId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, myUserId) AND STATUS = 'accepted'  AND NOT FIND_IN_SET(myId, myUserId)) AS derived;

	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @blockUserCoIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, blockUserId) AND STATUS = 'accepted' AND NOT FIND_IN_SET(coParentId, blockUserId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, blockUserId) AND STATUS = 'accepted'  AND NOT FIND_IN_SET(myId, blockUserId)) AS derived;

	IF EXISTS(SELECT * FROM `blockedusers` WHERE (blockedUserId = myUserId AND blockedBy = blockUserId) OR (blockedUserId = myUserId AND FIND_IN_SET(blockedBy, @blockUserCoIds))) THEN
        SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,smallProfileImage,isActive,isOnline,isParent,activeChildId,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds, @isPar AS isParentBlock, @isRes AS blockResult FROM parents WHERE parentId = blockUserId;
	ELSE
		IF EXISTS(SELECT * FROM `blockedusers` WHERE (blockedUserId = blockUserId AND FIND_IN_SET(blockedBy, @coIds)) OR (blockedUserId = blockUserId AND blockedBy = myUserId)) THEN
			SET @isPar = 1;
			SELECT  @isRes AS blockResult, @isPar AS isParentBlock;
		ELSE
		SET @isRes = 0;
		SELECT @isRes AS blockResult;
		END IF;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `checkInviterAndMyCoparentConnection` */

/*!50003 DROP PROCEDURE IF EXISTS  `checkInviterAndMyCoparentConnection` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `checkInviterAndMyCoparentConnection`(IN pId INT, IN inviterUserId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @coIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, pId) AND STATUS = 'accepted' AND NOT FIND_IN_SET(coParentId, pId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, pId) AND STATUS = 'accepted'  AND NOT FIND_IN_SET(myId, pId)) AS derived;
	SELECT GROUP_CONCAT(CONCAT(myFriendId,',',myId)) INTO @coFriendIds FROM (SELECT myFriendId, myId FROM friends WHERE `status` = 'accepted' AND (FIND_IN_SET(myFriendId, inviterUserId) OR FIND_IN_SET(myFriendId, @coIds)) AND (FIND_IN_SET(myId, inviterUserId) OR FIND_IN_SET(myId, @coIds))) AS derived;
	SELECT parentId,firstName,lastName,email,mobile,profileImage,smallProfileImage,isOnline,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents p WHERE FIND_IN_SET(parentId,@coFriendIds) AND isActive = 1 AND parentId != inviterUserId;

END */$$
DELIMITER ;

/* Procedure structure for procedure `checkPasscode` */

/*!50003 DROP PROCEDURE IF EXISTS  `checkPasscode` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `checkPasscode`(IN pId INT, IN `typ` VARCHAR(50))
BEGIN
	SET @isStripeExists = 0;
	IF EXISTS(SELECT * FROM `paymentdetails` WHERE parentId = pId) THEN
		SET @isStripeExists = 1;
	END IF;
	SELECT p.*,u.email,u.firstName, u.lastName, u.parentId AS uId, @isStripeExists AS isStripeExists FROM passcodes p JOIN parents u WHERE p.parentId = pId AND u.parentId = pId AND p.type= typ;
END */$$
DELIMITER ;

/* Procedure structure for procedure `createCallHistory` */

/*!50003 DROP PROCEDURE IF EXISTS  `createCallHistory` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `createCallHistory`(IN callerChildId INT, IN receiverChildId INT, IN uniqueCallId VARCHAR(100))
BEGIN
	SELECT parentId, firstName, lastName,havingCallhistory, profileImage INTO @callerParentId, @cfirstName, @clastName, @cchistory, @ccImage FROM `childrens` WHERE childId = callerChildId;
	SELECT parentId, firstName, lastName,havingCallhistory, profileImage INTO @receiverParentId, @rfirstName, @rlastName, @rchistory, @rcImage FROM `childrens` WHERE childId = receiverChildId;
	IF @cchistory = 0 THEN
	   UPDATE childrens SET havingCallhistory = 1 WHERE childId = callerChildId;
	END IF;
	IF @rchistory = 0 THEN
	   UPDATE childrens SET havingCallhistory = 1 WHERE childId = callerChildId;
	END IF;
	IF @callerParentId > 0 AND @receiverParentId > 0 THEN
	   INSERT INTO callhistory(callerChildId, callerParentId, receiverChildId, receiverParentId, callId) VALUES(callerChildId, @callerParentId, receiverChildId, @receiverParentId, uniqueCallId);
	   SELECT LAST_INSERT_ID() AS callId, @callerParentId AS callerParentId, @receiverParentId AS receiverParentId, @cfirstName AS callerFirstName, @clastName AS callerLastName,
	    @rfirstName AS receiverFirstName, @rlastName AS receiverLastName,@ccImage AS callerImage, @rcImage AS receiverImage, CURRENT_TIMESTAMP AS callAt;
	ELSE
	   SELECT 'Error' AS ERROR;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `deleteMyContact` */

/*!50003 DROP PROCEDURE IF EXISTS  `deleteMyContact` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `deleteMyContact`(IN myUserId INT, IN deleteId INT)
BEGIN
	SELECT COUNT(*) INTO @co FROM friends WHERE `status` = 'accepted' AND (myId = myUserId AND myFriendId = deleteId) OR (myFriendId = myUserId AND myId = deleteId);
	SELECT @co AS friendStatus;
	IF @co > 0 THEN
		SELECT * FROM friends WHERE `status` = 'accepted' AND (myId = myUserId AND myFriendId = deleteId) OR (myFriendId = myUserId AND myId = deleteId);
		DELETE FROM friends WHERE myId = myUserId AND myFriendId = deleteId OR myFriendId = myUserId AND myId = deleteId;
		DELETE FROM `hiddenusers` WHERE hiddenBy = myUserId AND hiddenUserId = deleteId;
		DELETE FROM `blockedusers` WHERE blockedBy = myUserId AND blockeduserId = deleteId; #need to check coz while invite we need to stop
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `endCallForDay` */

/*!50003 DROP PROCEDURE IF EXISTS  `endCallForDay` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `endCallForDay`()
BEGIN
	SELECT callId AS Id FROM callhistory WHERE DATEDIFF(CURRENT_TIMESTAMP,createdAt) > 1 AND callEndedAt IS NULL;
	UPDATE callhistory SET callEndedAt = (SELECT modifiedAt FROM snapshots WHERE snapshots.callId = callhistory.callId ORDER BY id DESC LIMIT 1) WHERE DATEDIFF(CURRENT_TIMESTAMP,createdAt) > 1 AND callEndedAt IS NULL AND ((SELECT COUNT(*) FROM snapshots WHERE snapshots.callId = callhistory.callId)>0);
	UPDATE callhistory SET callEndedAt = DATE_ADD(callStartedAt, INTERVAL 1 MINUTE) WHERE DATEDIFF(CURRENT_TIMESTAMP,createdAt) > 1 AND callEndedAt IS NULL;
	SELECT @callIds AS Ids;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getAllChildrenDetatils` */

/*!50003 DROP PROCEDURE IF EXISTS  `getAllChildrenDetatils` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getAllChildrenDetatils`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(myFriendId,',',myId)) INTO @friendIds FROM friends WHERE (myId = userId OR myFriendId = userId) AND `status` = "accepted" AND myFriendId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE blockedBy = userId);
	SELECT childrens.*, (SELECT email FROM parents WHERE parents.parentId = childrens.onlineParentId) AS email FROM childrens WHERE FIND_IN_SET(parentId,@friendIds) AND parentId != userId AND isDeleted = 0;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getBlockedContactChildrenDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getBlockedContactChildrenDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getBlockedContactChildrenDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(myFriendId,',',myId)) INTO @friendIds FROM friends WHERE (myId = userId OR myFriendId = userId) AND `status` = "accepted";
	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @coIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, userId) AND STATUS = 'accepted' AND NOT FIND_IN_SET(coParentId, userId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, userId) AND STATUS = 'accepted'  AND NOT FIND_IN_SET(myId, userId)) AS derived;
	SELECT GROUP_CONCAT(blockedUserId) INTO @blocketIds FROM `blockedusers` WHERE NOT FIND_IN_SET(blockedUserId, userId) AND (blockedBy = userId OR (FIND_IN_SET(blockedBy, @coIds)));
	SELECT childrens.*, (SELECT email FROM parents WHERE parents.parentId = childrens.onlineParentId) AS email FROM childrens WHERE FIND_IN_SET(parentId,@blocketIds) AND isDeleted = 0;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getBlockedContactDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getBlockedContactDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getBlockedContactDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(myFriendId,',',myId)) INTO @friendIds FROM friends WHERE (myId = userId OR myFriendId = userId) AND `status` = "accepted";
	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @coIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, userId) AND STATUS = 'accepted' AND NOT FIND_IN_SET(coParentId, userId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, userId) AND STATUS = 'accepted'  AND NOT FIND_IN_SET(myId, userId)) AS derived;
	#SELECT GROUP_CONCAT(blockedUserId) INTO @blocketIds FROM `blockedusers` WHERE blockedBy = userId;
	SELECT GROUP_CONCAT(blockedUserId) INTO @blocketIds FROM `blockedusers` WHERE NOT FIND_IN_SET(blockedUserId, userId) AND (blockedBy = userId OR (FIND_IN_SET(blockedBy, @coIds)));
	SELECT parentId,firstName,lastName,email,mobile,profileImage,smallProfileImage,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents p WHERE FIND_IN_SET(parentId,@blocketIds) AND isActive = 1 ;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getCallDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getCallDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getCallDetails`(IN pId INT, IN callId INT)
BEGIN
  IF EXISTS(SELECT * FROM `callhistory` WHERE id = callId AND (callerParentId = pId OR receiverParentId = pId)) THEN
	SELECT * FROM `callhistory` WHERE id = callId AND (callerParentId = pId OR receiverParentId = pId);
ELSEIF EXISTS(SELECT * FROM `callhistory` WHERE id = callId AND (callerParentId IN (SELECT DISTINCT parents.parentId FROM parents JOIN coparent cp WHERE parents.parentId = cp.myId OR parents.parentId = cp.coparentId AND (cp.myId = pId OR cp.coparentId = pId)) OR receiverParentId IN (SELECT DISTINCT parents.parentId FROM parents JOIN coparent cp WHERE parents.parentId = cp.myId OR parents.parentId = cp.coparentId AND (cp.myId = pId OR cp.coparentId = pId)))) THEN
	SELECT * FROM `callhistory` WHERE id = callId AND (callerParentId IN (SELECT DISTINCT parents.parentId FROM parents JOIN coparent cp WHERE parents.parentId = cp.myId OR parents.parentId = cp.coparentId AND (cp.myId = pId OR cp.coparentId = pId)) OR receiverParentId IN (SELECT DISTINCT parents.parentId FROM parents JOIN coparent cp WHERE parents.parentId = cp.myId OR parents.parentId = cp.coparentId AND (cp.myId = pId OR cp.coparentId = pId)));
  ELSE
	SELECT 'Error' AS ERROR;
  END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getCallHistoryForDeletedChild` */

/*!50003 DROP PROCEDURE IF EXISTS  `getCallHistoryForDeletedChild` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getCallHistoryForDeletedChild`()
BEGIN
  SELECT s.snapshotFileName AS snapshots,c.id AS id, c.callId AS callId FROM `snapshots` s
    JOIN `callhistory` c ON c.callId = s.callId
     JOIN `childrens` ch ON ch.childId = c.callerChildId
      JOIN `childrens` rch ON rch.childId = c.receiverChildId WHERE ch.isDeleted =1 AND rch.isDeleted =1;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getCoChildrenDetatils` */

/*!50003 DROP PROCEDURE IF EXISTS  `getCoChildrenDetatils` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getCoChildrenDetatils`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(coParentId,',',myId)) INTO @friendIds FROM coparent WHERE (myId = userId OR coParentId = userId) AND `status` = 'accepted';
	SELECT childrens.*, (SELECT email FROM parents WHERE parents.parentId = childrens.onlineParentId) AS email FROM childrens WHERE FIND_IN_SET(parentId,@friendIds) AND isDeleted = 0;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getCoParentChildrenDetatils` */

/*!50003 DROP PROCEDURE IF EXISTS  `getCoParentChildrenDetatils` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getCoParentChildrenDetatils`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(coParentId,',',myId)) INTO @friendIds FROM coparent WHERE (myId = userId OR coParentId = userId) AND `status` = 'accepted';
	SELECT childrens.*, (SELECT email FROM parents WHERE parents.parentId = childrens.onlineParentId) AS email FROM childrens WHERE FIND_IN_SET(parentId,@friendIds) AND isDeleted = 0;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getCoParentContactDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getCoParentContactDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getCoParentContactDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(coParentId,',',myId)) INTO @friendIds FROM coparent WHERE (myId = userId OR coParentId = userId) AND `status` = 'accepted';
	SELECT parentId,firstName,lastName,email,mobile,profileImage,smallProfileImage,isOnline,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents p WHERE FIND_IN_SET(parentId,@friendIds) AND isActive = 1 AND parentId != userid;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getCoParentFriendChildDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getCoParentFriendChildDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getCoParentFriendChildDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @coIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, userId) AND STATUS = 'accepted' AND NOT FIND_IN_SET(coParentId, userId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, userId) AND STATUS = 'accepted'  AND NOT FIND_IN_SET(myId, userId)) AS derived;
	SELECT GROUP_CONCAT(CONCAT(myFriendId)) INTO @coFriendids FROM (SELECT myFriendId  FROM friends WHERE FIND_IN_SET(myId, @coIds) AND STATUS = 'accepted' AND (myFriendId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE blockedBy = userId)) AND (myFriendId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE FIND_IN_SET(blockedBy, @coIds))) UNION SELECT myId FROM friends WHERE FIND_IN_SET(myFriendId, @coIds) AND STATUS = 'accepted' AND (myId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE blockedBy = userId)) AND (myId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE FIND_IN_SET(blockedBy, @coIds)))) AS derived;
	SELECT childrens.*, (SELECT email FROM parents WHERE parents.parentId = childrens.onlineParentId) AS email FROM childrens WHERE FIND_IN_SET(parentId,@coFriendids) AND isDeleted = 0;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getCoParentFriendDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getCoParentFriendDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getCoParentFriendDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @coIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, userId) AND STATUS = 'accepted' AND NOT FIND_IN_SET(coParentId, userId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, userId) AND STATUS = 'accepted'  AND NOT FIND_IN_SET(myId, userId)) AS derived;
	SELECT GROUP_CONCAT(CONCAT(myFriendId)) INTO @coFriendids FROM (SELECT myFriendId  FROM friends WHERE FIND_IN_SET(myId, @coIds) AND STATUS = 'accepted' AND (myFriendId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE blockedBy = userId)) AND (myFriendId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE FIND_IN_SET(blockedBy, @coIds))) UNION SELECT myId FROM friends WHERE FIND_IN_SET(myFriendId, @coIds) AND STATUS = 'accepted' AND (myId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE blockedBy = userId)) AND (myId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE FIND_IN_SET(blockedBy, @coIds)))) AS derived;
	SELECT parentId,firstName,lastName,email,mobile,profileImage,smallProfileImage,isOnline,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents p WHERE FIND_IN_SET(parentId,@coFriendids) AND isActive = 1 AND parentId != userId;

END */$$
DELIMITER ;

/* Procedure structure for procedure `getDeviceToken` */

/*!50003 DROP PROCEDURE IF EXISTS  `getDeviceToken` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getDeviceToken`(IN uId INT, IN chActive TINYINT, IN topic VARCHAR(100))
BEGIN
SET @co = NULL;
	IF topic = 'coparent invite' THEN
		SELECT COUNT(*) INTO @co FROM coparent WHERE coParentId = uId AND `status` = 'pending';
	ELSEIF topic = 'friend invite' THEN
		SELECT COUNT(*) INTO @co FROM friends WHERE myFriendId = uId AND `status` = 'pending';
	END IF;
	#if chActive != 0 then
	#select deviceType,token,fcmToken,@co AS badgeCount   FROM pushtokendetails WHERE parentId = uId and isTablet = 0;
#else
	SELECT deviceType,token,fcmToken,platformEndpoint FROM pushtokendetails WHERE parentId = uId;
	SELECT @co AS `count`;
	#END IF;
	#need to calculate the badge count
END */$$
DELIMITER ;

/* Procedure structure for procedure `getInvitedCoParents` */

/*!50003 DROP PROCEDURE IF EXISTS  `getInvitedCoParents` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getInvitedCoParents`(IN inviterUserId INT)
BEGIN
	SELECT GROUP_CONCAT(inviteeMobile) INTO @im  FROM invitecoparent WHERE inviterId = inviterUserId;
	SELECT GROUP_CONCAT(mobile) INTO @ifm FROM parents WHERE parentId IN (SELECT coParentId FROM coparent WHERE myId = inviterUserId AND `status` = 'pending');
	SELECT @im AS inviteMobile, @ifm AS inviteFriendMobile;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getInvitedUser` */

/*!50003 DROP PROCEDURE IF EXISTS  `getInvitedUser` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getInvitedUser`(IN inviterUserId INT)
BEGIN
	SELECT GROUP_CONCAT(inviteeMobile) INTO @im  FROM inviteusers WHERE inviterId = inviterUserId;
	SELECT GROUP_CONCAT(mobile) INTO @ifm FROM parents WHERE parentId IN (SELECT myFriendId FROM friends WHERE myId = inviterUserId AND `status` = 'pending');
	SELECT @im AS inviteMobile, @ifm AS inviteFriendMobile;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getOneMonthAgoOldCallHistory` */

/*!50003 DROP PROCEDURE IF EXISTS  `getOneMonthAgoOldCallHistory` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getOneMonthAgoOldCallHistory`()
BEGIN
      SELECT * FROM callhistory  WHERE DATEDIFF(CURRENT_TIMESTAMP,createdAt) > 30;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getPendingContactChildrenDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getPendingContactChildrenDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getPendingContactChildrenDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(myId) INTO @friendIds FROM friends WHERE myFriendId = userId AND `status` = 'pending';
	SELECT childrens.*, (SELECT email FROM parents WHERE parents.parentId = childrens.onlineParentId) AS email FROM childrens WHERE FIND_IN_SET(parentId,@friendIds) AND isDeleted = 0;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getPendingContactDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getPendingContactDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getPendingContactDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(myId) INTO @friendIds FROM friends WHERE myFriendId = userId AND `status` = 'pending';
	SELECT parentId,firstName,lastName,email,mobile,profileImage,smallProfileImage,isOnline,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents p WHERE FIND_IN_SET(parentId,@friendIds) AND isActive = 1;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getPendingCoParentChildrenDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getPendingCoParentChildrenDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getPendingCoParentChildrenDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(myId) INTO @friendIds FROM coparent WHERE coParentId = userId AND `status` = 'pending';
	SELECT childrens.*, (SELECT email FROM parents WHERE parents.parentId = childrens.onlineParentId) AS email FROM childrens WHERE FIND_IN_SET(parentId,@friendIds) AND isDeleted = 0;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getPendingCoParentDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `getPendingCoParentDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getPendingCoParentDetails`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(myId) INTO @friendIds FROM coparent WHERE coParentId = userId AND `status` = 'pending';
	SELECT parentId,firstName,lastName,email,mobile,profileImage,smallProfileImage,isOnline,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents p WHERE FIND_IN_SET(parentId,@friendIds) AND isActive = 1;
END */$$
DELIMITER ;

/* Procedure structure for procedure `hideMyContact` */

/*!50003 DROP PROCEDURE IF EXISTS  `hideMyContact` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `hideMyContact`(IN myUserId INT, IN hideUserId INT)
BEGIN
	SELECT COUNT(*) INTO @co FROM `hiddenusers` WHERE hiddenBy = myUserId AND hiddenUserId = hideUserId;
	IF @co = 0 THEN
	     INSERT INTO `hiddenusers` (hiddenBy, hiddenUserId) VALUES (myUserId, hideUserId);
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `insertSessionDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `insertSessionDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `insertSessionDetails`(IN pId INT, IN dId TEXT, IN tok TEXT, IN ismob INT, IN oldToken VARCHAR(255))
BEGIN
	SELECT COUNT(*) INTO @co FROM `session` WHERE parentId = pId AND token = oldToken;
	IF @co > 0 THEN
		UPDATE `session` SET token = tok, currentDeviceId = dId WHERE parentId = pId AND token = oldToken;
	ELSE
		INSERT INTO `session` (parentId, token, currentDeviceId, isMobile) VALUES (pId, tok, dId, ismob);
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `insertUserDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `insertUserDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `insertUserDetails`(IN mobile TEXT, IN deviceId VARCHAR(255), IN tok TEXT, IN step INT, IN attempts INT, IN loggedTime DATETIME, IN userId INT, IN isact INT)
BEGIN
	SET @isMob = 1;
	IF deviceId LIKE 'PlayDate_%' THEN
		SET @isMob = 0;
		UPDATE parents SET stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime, mobile = mobile, isActive = isact, verifiedOn = CURRENT_TIMESTAMP WHERE parentId = userId;
	ELSE
		IF EXISTS(SELECT * FROM parents WHERE lastLoggedInDevice LIKE CONCAT ('%', deviceId, '%')) THEN
		        UPDATE parents SET stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime, mobile = mobile, isActive = isact, verifiedOn = CURRENT_TIMESTAMP WHERE parentId = userId;
		ELSE
			UPDATE parents SET lastLoggedInDevice = CONCAT(lastLoggedInDevice, "||" ,deviceId), stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime, mobile = mobile, isActive = isact, verifiedOn = CURRENT_TIMESTAMP WHERE parentId = userId;
		END IF;
	END IF;
	SELECT email, mobile INTO @em,@mob FROM parents WHERE parentId = userId;
	SELECT COUNT(*) INTO @co FROM `session` WHERE isMobile = @isMob AND currentDeviceId = deviceId;
	IF @co > 0 THEN
		UPDATE `session` SET token =  tok,isMobile = @isMob, parentId = userId, currentDeviceId = deviceId   WHERE isMobile = @isMob AND currentDeviceId = deviceId;
	ELSE
		INSERT INTO `session` (parentId, token, isMobile,currentDeviceId) VALUES (userId, tok, @isMob, deviceId);
	END IF;
	INSERT INTO friends (myId, myFriendId, `status`) SELECT DISTINCT inviterId, userId, 'pending' FROM `inviteusers` WHERE inviteeEmail = @em OR inviteeMobile = @mob;
	DELETE FROM inviteusers WHERE inviteeEmail = @em OR inviteeMobile = @mob;
	INSERT INTO coparent (myId, coParentId, `status`) SELECT DISTINCT inviterId, userId, 'pending' FROM `invitecoparent` WHERE inviteeEmail = @em OR inviteeMobile = @mob;
	DELETE FROM invitecoparent WHERE inviteeEmail = @em OR inviteeMobile = @mob;
	SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,smallProfileImage,isOnline,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents WHERE parentId = userid ;
END */$$
DELIMITER ;

/* Procedure structure for procedure `removeDeletedChildData` */

/*!50003 DROP PROCEDURE IF EXISTS  `removeDeletedChildData` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `removeDeletedChildData`(IN snapshots TEXT)
BEGIN
	SELECT * FROM snapshots WHERE callId = snapshots;
	DELETE FROM snapshots WHERE  callId IN (snapshots);
	DELETE FROM callhistory WHERE  callId IN (snapshots);
END */$$
DELIMITER ;

/* Procedure structure for procedure `saveFcmToken` */

/*!50003 DROP PROCEDURE IF EXISTS  `saveFcmToken` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `saveFcmToken`(IN dId VARCHAR(255), IN uId INT, IN dType VARCHAR(10), IN fcm VARCHAR(255))
BEGIN
#DELETE FROM pushtokendetails WHERE deviceId = dId;
IF EXISTS(SELECT * FROM pushtokendetails WHERE deviceId = dId) THEN
	UPDATE pushtokendetails SET parentId = uId, fcmToken = fcm, platformEndpoint = NULL WHERE deviceId = dId;
ELSE
	INSERT INTO pushtokendetails (deviceId, parentId, deviceType, fcmToken) VALUES (dId, uId, dType, fcm);
END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `savePushToken` */

/*!50003 DROP PROCEDURE IF EXISTS  `savePushToken` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `savePushToken`(IN dId VARCHAR(255), IN uId INT, IN dType VARCHAR(10), IN tok VARCHAR(255), IN appVer INT, IN fcm VARCHAR(255), IN lId TINYINT(2), IN isTab TINYINT(2))
BEGIN
#DELETE FROM pushtokendetails WHERE deviceId = dId;
SELECT COUNT(*) INTO @device_count FROM pushtokendetails WHERE deviceId = dId;
IF EXISTS(SELECT * FROM pushtokendetails WHERE  deviceId = dId OR token = tok OR fcmToken = fcm) AND dType = 'ANDROID' THEN
	UPDATE pushtokendetails SET parentId = uId, deviceId = dId, deviceType = dType, token = tok, fcmToken = fcm, appVersion = appVer, isTablet =  isTab, isUserLogIn = lId, platformEndpoint = NULL WHERE deviceId = dId OR token = tok OR fcmToken = fcm;

ELSEIF EXISTS(SELECT * FROM pushtokendetails WHERE  deviceId = dId) AND dType != 'ANDROID' THEN
	UPDATE pushtokendetails SET parentId = uId, deviceId = dId, token = tok, deviceType = dType, appVersion = appVer, isUserLogIn = lId, isTablet = isTab, platformEndpoint = NULL WHERE deviceId = dId;
ELSE
	INSERT INTO pushtokendetails (deviceId, parentId, deviceType, token, fcmToken, appVersion, isUserLogIn, isTablet) VALUES (dId, uId, dType, tok, fcm, appVer, lId, isTab);
END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `unBlockMyContact` */

/*!50003 DROP PROCEDURE IF EXISTS  `unBlockMyContact` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `unBlockMyContact`(IN myUserId INT, IN blockUserId INT)
BEGIN
	DELETE FROM blockedusers WHERE blockedBy = myUserId AND blockedUserId  = blockUserId;
	SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,smallProfileImage,isActive,isOnline,isParent, activeChildId,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds, (SELECT `status` FROM friends WHERE (myId = myUserId AND myFriendId = blockUserId) OR (myId = blockUserId  AND myFriendId = myUserId)) AS `status` FROM parents WHERE parentId = blockUserId LIMIT 1;
	UPDATE `friends` SET `status` = 'pending' WHERE ((myId = myUserId AND myFriendId = blockUserId) OR (myId = blockUserId  AND myFriendId = myUserId)) AND `status` = 'blocked';
	SELECT COUNT(*) INTO @co FROM friends WHERE `status` = 'pending' AND ((myId = myUserId AND myFriendId = blockUserId) OR (myId = blockUserId  AND myFriendId = myUserId)) LIMIT 1;
	SELECT @co AS `isPendingConnection`;
	IF @co > 0 THEN
	SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,smallProfileImage,isActive,isOnline,isParent, activeChildId,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents WHERE parentId = myUserId ;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateChildOnline` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateChildOnline` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateChildOnline`(IN pId INT, IN cId INT, IN chOnline TINYINT)
BEGIN
	SET @isOffline = 0;
	SELECT COUNT(*) INTO @co FROM `childrens` WHERE isOnline = 1 AND onlineParentId = pId AND childId = cId LIMIT 1;
	IF chOnline = 1 THEN
		IF @co = 0 THEN
			UPDATE childrens SET isOnline = chOnline, onlineParentId = pId WHERE childId = cId; #make childOnline
			SET @isOffline = 1;
		END IF;
		UPDATE `childrens` SET isOnline = 0, onlineParentId = 0 WHERE childId = cId;  #To calculate the modifiedAt sec value for cron
	END IF;
	UPDATE `childrens` SET isOnline = chOnline, onlineParentId = pId WHERE childId = cId;
	IF chOnline = 0 THEN
			UPDATE childrens SET isOnline = 0, onlineParentId = 0 WHERE childId = cId; #make childOffline
	END IF;
	SELECT @isOffline AS isChildOffline;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateConnection` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateConnection` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateConnection`(IN inviterId INT, IN inviteeId INT)
BEGIN
	SET @istatus := "" ;
	SELECT COUNT(*),`status` INTO @count, @istatus FROM `friends` WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
	IF @count = 0 THEN
		INSERT INTO `friends` (myId, myFriendId, `status`) VALUES (inviterId, inviteeId, 'pending');
	ELSEIF @istatus = 'rejected' THEN
		UPDATE `friends` SET `status` = 'pending',myId = inviterId, myFriendId = inviteeId WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
	ELSEIF @istatus = 'pending' THEN
		UPDATE `friends` SET `status` = 'pending',myId = inviterId, myFriendId = inviteeId WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
	ELSEIF @count > 0 THEN
		SELECT 'Error' AS ERROR;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateCoParentConnection` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateCoParentConnection` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateCoParentConnection`(IN inviterId INT, IN inviteeId INT)
BEGIN
	SET @istatus := "" ;
	SELECT COUNT(*),`status` INTO @count, @istatus FROM `coparent` WHERE (myId = inviterId AND coParentId = inviteeId) OR (coParentId = inviteeId AND myId = inviterId);
	IF @count = 0 THEN
		INSERT INTO `coparent` (myId, coParentId, `status`) VALUES (inviterId, inviteeId, 'pending');
	ELSEIF @istatus = 'rejected' THEN
		UPDATE `coparent` SET `status` = 'pending',myId = inviterId, coParentId = inviteeId WHERE (myId = inviterId AND coParentId = inviteeId) OR (coParentId = inviteeId AND myId = inviterId);
	ELSEIF @istatus = 'pending' THEN
		UPDATE `coparent` SET `status` = 'pending',myId = inviterId, coParentId = inviteeId WHERE (myId = inviterId AND coParentId = inviteeId) OR (coParentId = inviteeId AND myId = inviterId);
	ELSEIF @count > 0 THEN
		SELECT 'Error' AS ERROR;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateCoParentInviteList` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateCoParentInviteList` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateCoParentInviteList`(IN mobile TEXT, IN email TEXT, IN inviterUserId INT, IN isConfirmed INT, IN isReInvite INT, IN isRemoved INT)
BEGIN
	IF mobile = '' THEN
	     SELECT COUNT(*) INTO @co  FROM invitecoparent WHERE inviteeEmail = email AND inviterId = inviterUserId LIMIT 1;
	ELSE
	     SELECT COUNT(*) INTO @co  FROM invitecoparent WHERE  inviteeMobile = mobile AND inviterId = inviterUserId LIMIT 1;
	END IF;
	IF isConfirmed = '1' THEN
		IF @co = 0 THEN
			IF isRemoved = '1' THEN
				SELECT @co AS `count`;
			ELSE
				INSERT INTO invitecoparent (inviterId, inviteeEmail, inviteeMobile) VALUES (inviterUserId, email, mobile);
				SELECT @co AS `count`;
			END IF;
		ELSE
			SELECT @co AS `count`;
		END IF;
	ELSE
		SELECT @co AS `count`;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateCoParentResponse` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateCoParentResponse` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateCoParentResponse`(IN inviterId INT, IN inviteeId INT, IN `coStatus` VARCHAR(50))
BEGIN
	SELECT COUNT(*),`status` INTO @count, @istatus FROM `friends` WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
	SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,smallProfileImage,isActive,isOnline,isParent,activeChildId,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents WHERE parentId = inviterId LIMIT 1;
	IF `coStatus` = 'accepted' THEN
		UPDATE `coparent` SET `status` = 'accepted' WHERE (myId = inviterId AND coParentId = inviteeId) OR (coParentId = inviteeId AND myId = inviterId);
		IF @count > 0 THEN
		DELETE FROM friends WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myFriendId = inviterId AND myId = inviteeId);
		SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,smallProfileImage,isActive,isOnline,isParent,activeChildId,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds,@count AS `count`,@istatus AS `friendStatus` FROM parents WHERE parentId = inviteeId LIMIT 1;
		END IF;
	ELSEIF `coStatus` = 'rejected' THEN
		UPDATE `coparent` SET `status` = 'rejected' WHERE (myId = inviterId AND coParentId = inviteeId) OR (coParentId = inviteeId AND myId = inviterId);
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateEndCall` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateEndCall` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateEndCall`(IN cId VARCHAR(256))
BEGIN
	SELECT callerParentId, receiverParentId, callerChildId, receiverChildId, callEndedAt INTO @cPId, @rPId, @cChildId, @rChildId, @cEndedAt FROM `callhistory` WHERE callId = cId;
	IF @cEndedAt IS NULL THEN
	   UPDATE callhistory SET callEndedAt = CURRENT_TIMESTAMP WHERE callId = cId;
	END IF;
	SELECT firstName INTO @cName FROM `childrens` WHERE childId =  @cChildId;
	SELECT firstName INTO @rName FROM `childrens` WHERE childId =  @rChildId;
	SELECT COUNT(*) INTO @cSnap FROM snapshots WHERE callId = cId AND parentId = @cPId;
	SELECT COUNT(*) INTO @rSnap FROM snapshots WHERE callId = cId AND parentId = @rPId;
	SELECT @cEndedAt AS callEnded, @cSnap AS callerSnapCount, @rSnap AS receiverSnapCount, @cName AS callerChildName, @rName AS receiverChildName;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateInvite` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateInvite` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateInvite`(IN mobile TEXT, IN email TEXT, IN inviterUserId INT, IN isConfirmed INT, IN isReInvite INT, IN isRemoved INT)
BEGIN
	IF mobile = '' THEN
	     SELECT COUNT(*) INTO @co  FROM inviteusers WHERE inviteeEmail = email AND inviterId = inviterUserId LIMIT 1;
	ELSE
	     SELECT COUNT(*) INTO @co  FROM inviteusers WHERE  inviteeMobile = mobile AND inviterId = inviterUserId LIMIT 1;
	END IF;
	IF isConfirmed = '1' THEN
		IF @co = 0 THEN
			IF isRemoved = '1' THEN
				SELECT @co AS `count`;
			ELSE
				INSERT INTO inviteusers (inviterId, inviteeEmail, inviteeMobile) VALUES (inviterUserId, email, mobile);
				SELECT @co AS `count`;
			END IF;
		ELSE
			SELECT @co AS `count`;
		END IF;
	ELSE
		SELECT @co AS `count`;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateInvitedResponse` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateInvitedResponse` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateInvitedResponse`(IN inviterId INT, IN inviteeId INT, IN `status` VARCHAR(50))
BEGIN
	SELECT * FROM `friends` WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
	IF `status` = 'accepted' THEN
		UPDATE `friends` SET `status` = 'accepted' WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
	ELSEIF `status` = 'rejected' THEN
		UPDATE `friends` SET `status` = 'rejected' WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
	ELSEIF `status` = 'blocked' THEN
		UPDATE `friends` SET `status` = 'blocked' WHERE (myId = inviterId AND myFriendId = inviteeId) OR (myId = inviteeId  AND myFriendId = inviterId);
		SELECT COUNT(*) INTO @co FROM `blockedusers` WHERE blockedUserId = inviterId AND blockedBy = inviteeId;
		IF @co = 0 THEN
			INSERT INTO `blockedusers`(blockedUserId, blockedBy) VALUES ( inviteeId, inviterId);
		END IF;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateLoginDetailsFromForgetPassword` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateLoginDetailsFromForgetPassword` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateLoginDetailsFromForgetPassword`(IN pass VARCHAR(255), IN deviceId VARCHAR(255), IN tok TEXT, IN step INT, IN attempts INT, IN loggedTime DATETIME, IN userId INT)
BEGIN
	SET @isMob = 1;
	IF deviceId LIKE 'PlayDate_%' THEN
		SET @isMob = 0;
		UPDATE parents SET stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime, `password` = pass WHERE parentId = userId;
	ELSE
		IF EXISTS(SELECT * FROM parents WHERE lastLoggedInDevice LIKE CONCAT ('%', deviceId, '%')) THEN
		        UPDATE parents SET stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime, `password` = pass WHERE parentId = userId;
		ELSE
			UPDATE parents SET lastLoggedInDevice = CONCAT(lastLoggedInDevice, "||",deviceId), stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime, `password` = pass WHERE parentId = userId;
		END IF;
	END IF;
	SELECT COUNT(*) INTO @co FROM `session` WHERE parentId  = userId AND isMobile = @isMob;
	IF @co > 0 THEN
		UPDATE `session` SET token =  tok, isMobile = @isMob, parentId = userId, currentDeviceId = deviceId   WHERE parentId = userId;
	ELSE
		INSERT INTO `session` (parentId, token,isMobile) VALUES (userId, tok, @isMob);
	END IF;
	SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,isActive,isOnline,isParent, activeChildId,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents WHERE parentId = userId ;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updatePasscode` */

/*!50003 DROP PROCEDURE IF EXISTS  `updatePasscode` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updatePasscode`(IN mob VARCHAR(15), IN pass VARCHAR(10), IN `passcodeType` VARCHAR(50), IN Id INT)
BEGIN
	SELECT COUNT(*) INTO @co FROM passcodes WHERE  parentId = Id AND `type` = passcodeType;
	IF @co > 0 THEN
		DELETE FROM passcodes WHERE parentId = Id AND `type` = passcodeType;
		INSERT INTO passcodes (parentId, passcode, TYPE) VALUES (Id, pass, passcodeType);
	ELSE
		INSERT INTO passcodes (parentId, passcode, TYPE) VALUES (Id, pass, passcodeType);
	END IF;
	SELECT parentId, passcode FROM passcodes WHERE parentId = Id AND `type` = passcodeType;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updatePasscodeByEmail` */

/*!50003 DROP PROCEDURE IF EXISTS  `updatePasscodeByEmail` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updatePasscodeByEmail`(IN pass VARCHAR(10), IN `passcodeType` VARCHAR(50), IN em TEXT)
BEGIN
	SELECT COUNT(*), parentId INTO @isExist,@Id FROM parents WHERE email = em AND isActive = 1;
	IF @isExist <> 0 THEN
		SELECT COUNT(*) INTO @c FROM passcodes WHERE  parentId = @Id AND `type` = passcodeType;
			IF @c > 0 THEN
				DELETE FROM passcodes WHERE parentId = @Id AND `type` = passcodeType;
				INSERT INTO passcodes (parentId, passcode, TYPE) VALUES (@Id, pass, passcodeType);
			ELSE
				INSERT INTO passcodes (parentId, passcode, TYPE) VALUES (@Id, pass, passcodeType);
			END IF;
		SELECT parentId, passcode FROM passcodes WHERE parentId = @Id AND `type` = passcodeType;
	ELSE
		SELECT 'Error' AS ERROR;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateStep` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateStep` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateStep`(IN step INT, IN `uid` INT)
BEGIN
	UPDATE parents SET stepJumpto = step WHERE parentId = uid;
	SELECT * FROM parents WHERE parentId = uid;
END */$$
DELIMITER ;

/* Procedure structure for procedure `updateLoginDetails` */

/*!50003 DROP PROCEDURE IF EXISTS  `updateLoginDetails` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `updateLoginDetails`(IN deviceId VARCHAR(255), IN tok TEXT, IN step INT, IN attempts INT, IN loggedTime DATETIME, IN userId INT, IN isTab TINYINT(2))
BEGIN
	SET @isMob = 1;
	IF deviceId LIKE 'PlayDate_%' THEN
		SET @isMob = 0;
		UPDATE parents SET stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime WHERE parentId = userId;
	ELSE
		UPDATE parents SET lastLoggedInDevice = deviceId, stepJumpTo = step, loginAttempts = attempts, lastLoggedAt = loggedTime WHERE parentId = userId;
	END IF;
	IF EXISTS (SELECT * FROM `session` WHERE isMobile = @isMob AND currentDeviceId = deviceId) THEN
		UPDATE `session` SET token =  tok, isMobile = @isMob, parentId = userId, currentDeviceId = deviceId  WHERE isMobile = @isMob AND currentDeviceId = deviceId;
	ELSE
		INSERT INTO `session` (parentId, token, isMobile, currentDeviceId, isTablet) VALUES (userId, tok, @isMob, deviceId, isTab);
	END IF;
	SELECT parentId,firstName,lastName,email,mobile,userName,profileImage,smallProfileImage,isActive,isOnline,isParent, activeChildId,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents WHERE parentId = userId ;
END */$$
DELIMITER ;

/* Procedure structure for procedure `registrationStep1` */

/*!50003 DROP PROCEDURE IF EXISTS  `registrationStep1` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `registrationStep1`(IN mail TEXT, IN pass TEXT, IN step INT)
BEGIN
SET @uid := 0;
	SELECT parentId INTO @uid FROM parents WHERE email = mail LIMIT 1;
	IF @uid <> 0 THEN
		UPDATE parents SET email= mail,`password` = pass, stepJumpTo = step, createdOn = CURRENT_TIMESTAMP(3) WHERE parentId = @uid;
	ELSE
		INSERT INTO parents (email,`password`,stepJumpTo,createdOn) VALUES (mail, pass, step, CURRENT_TIMESTAMP(3));
	END IF;
	SELECT parentId, stepJumpTo, email FROM parents WHERE email = mail LIMIT 1;
END */$$
DELIMITER ;

/* Procedure structure for procedure `registrationStep2` */

/*!50003 DROP PROCEDURE IF EXISTS  `registrationStep2` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `registrationStep2`(IN firstName TEXT, IN lastName TEXT, IN profileImage TEXT, IN smallPImage TEXT, IN stepJumpTo INT, IN em TEXT)
BEGIN
	IF EXISTS (SELECT parentId FROM parents WHERE email = em LIMIT 1) THEN
		UPDATE parents SET firstName = firstName, lastName = lastName, profileImage = profileImage, smallProfileImage = smallPImage, stepJumpTo = stepJumpTo WHERE email = em;
		SELECT parentId, stepJumpTo FROM parents WHERE email = em;
	ELSE
		SELECT "Error";
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `logoutUser` */

/*!50003 DROP PROCEDURE IF EXISTS  `logoutUser` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `logoutUser`(IN uId INT, IN isMob INT, IN dId VARCHAR(255))
BEGIN
	UPDATE parents SET isOnline = 0 WHERE parentId = uId;
	SELECT COUNT(*) INTO @co FROM pushtokendetails WHERE parentId = uId;
	IF @co = 1 THEN
	UPDATE `childrens` SET isOnline = 0 WHERE parentId = uId;
	END IF;
	#if isMob = 1 then
		DELETE FROM `pushtokendetails` WHERE parentId = uId  AND deviceId = dId;
	#end if;
	DELETE FROM `session` WHERE parentId = uId AND isMobile = isMob AND currentDeviceId = dId;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getFcmToken` */

/*!50003 DROP PROCEDURE IF EXISTS  `getFcmToken` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getFcmToken`(IN userId INT, IN tok TEXT)
BEGIN
	IF tok IS NULL THEN
	SELECT * FROM `pushtokendetails` WHERE parentId = userId AND isUserLogIn = '1' AND fcmToken IS NOT NULL;
	ELSE
	SELECT currentDeviceId INTO @dId FROM `session` WHERE parentId = userId AND token = tok;
	SELECT * FROM `pushtokendetails` WHERE parentId = userId AND isUserLogIn = '1' AND fcmToken IS NOT NULL AND deviceId != @dId;
	END IF;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getAllContact` */

/*!50003 DROP PROCEDURE IF EXISTS  `getAllContact` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getAllContact`(IN userId INT)
BEGIN
	SELECT GROUP_CONCAT(CONCAT(coParentId)) INTO @coIds FROM (SELECT coParentId  FROM coparent WHERE FIND_IN_SET(myId, userId) AND `status` = 'accepted' AND NOT FIND_IN_SET(coParentId, userId) UNION SELECT myId FROM coparent WHERE FIND_IN_SET(coParentId, userId) AND `status` = 'accepted'  AND NOT FIND_IN_SET(myId, userId)) AS derived;
	SELECT GROUP_CONCAT(CONCAT(myFriendId,',',myId)) INTO @friendIds FROM friends WHERE (myId = userId OR myFriendId = userId) AND `status` = 'accepted' AND (myFriendId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE blockedBy = userId) AND myId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE blockedBy = userId)) AND (myFriendId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE FIND_IN_SET(blockedBy, @coIds)) AND myId NOT IN (SELECT blockedUserId FROM `blockedusers` WHERE FIND_IN_SET(blockedBy, @coIds)));
	SELECT parentId,firstName,lastName,email,mobile,profileImage,smallProfileImage,isOnline,connectedParentIds,inviteFriendReadIds,inviteCoParentReadIds FROM parents p WHERE FIND_IN_SET(parentId,@friendIds) AND isActive = 1 AND parentId != userId;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getAllCallHistory` */

/*!50003 DROP PROCEDURE IF EXISTS  `getAllCallHistory` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`webuser`@`%` PROCEDURE `getAllCallHistory`(IN pId INT)
BEGIN
  SELECT c.id AS callId, c.callId AS callIdentifier, c.callStartedAt AS callAt, c.callEndedAt AS callEndAt, c.callerParentId ,p.firstName AS CallerParentFirstName,
   p.lastName AS CallerParentLastName, c.receiverParentId, rp.firstName AS ReceiverParentFirstName, rp.lastName AS ReceiverParentLastName , c.receiverChildId,
    rch.firstName AS ReceiverChildFirstName, rch.lastName AS ReceiverChildLastName, rch.profileImage AS ReceiverChildImage, rch.smallProfileImage AS ReceiverChildSmallImage, c.callerChildId, ch.firstName AS CallerChildFirstName,
     ch.lastName AS CallerChildLastName, ch.profileImage AS CallerChildImage, ch.smallProfileImage AS CallerChildSmallImage, c.viewParentId AS viewParentId, ch.isDeleted AS callerChildIsDeleted, rch.isDeleted AS receiverChildIsDeleted FROM `callhistory` c JOIN parents p ON p.parentId = c.callerParentId
      JOIN parents rp ON rp.parentId = c.receiverParentId
       JOIN `childrens` ch ON ch.childId = c.callerChildId
        JOIN `childrens` rch ON rch.childId = c.receiverChildId
         WHERE (c.callerParentId = pId OR c.receiverParentId = pId) AND ch.isEnabled =1 AND rch.isEnabled =1;
END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;