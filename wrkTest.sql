use db;
select * from components;
select * from clients;
-- describe clients;

use db;
insert into components(name, type, description, cost, count) values(
    'Intel Core i7-10700K', 0, 'Desktop Processor 8 Cores up to 5.1 GHz Unlocked LGA1200', 2000, 10);
insert into components(name, type, description, cost, count) values(
    'Intel Core i9-12900K', 0, 'Desktop Processor 16 (8P+8E) Cores up to 5.2 GHz Unlocked LGA1700', 3000, 5);
insert into components(name, type, description, cost, count) values(
    'Intel Core i9-11900K', 0, 'Desktop Processor 8 Cores up to 5.3 GHz Unlocked LGA1200', 2500, 8);
insert into components(name, type, description, cost, count) values(
    'AMD Ryzen™ 9 7950X', 0, '16-Core, 32-Thread Unlocked Desktop Processor', 3000, 10);
insert into components(name, type, description, cost, count) values(
    'AMD Ryzen 5 5600X 6-core', 0, '12-Thread Unlocked Desktop Processor with Wraith Stealth Cooler', 1500, 10);
insert into components(name, type, description, cost, count) values(
    'AMD Ryzen 7 5800X 8-core', 0, '16-Thread Unlocked Desktop Processor', 2500, 10);
insert into components(name, type, description, cost, count) values(
    'NVIDIA Quadro P2200', 2, 'Video Graphic Cards (VCQP2200-SB)', 1000, 10);
insert into components(name, type, description, cost, count) values(
    'NVIDIA GeForce RTX 3060 Ti', 2, 'Founders Edition 8GB GDDR6 PCI Express 4.0 Graphics Card', 5000, 10);
insert into components(name, type, description, cost, count) values(
    'AMD Radeon PRO W5500 8GB', 2, '', 1500, 10);
insert into components(name, type, description, cost, count) values(
    'AMD Radeon RX 6800 XT', 2, 'Reference Edition Gaming Graphics Card', 1500, 10);

insert into clients(name, surname, phone, address, email, password) values(
    'John', 'Johnson', 1234567890, 'Georg Street 22', 'john_j@email.com',
    '$2a$12$iV0DP3E5Q6Ppxj.wVyXiG.LQyd/39vD2vcnDIyaHhOOYIiP.TXkm2');
insert into clients(name, surname, phone, address, email, password) values(
    'Tom', 'Thomson', 1200517891, 'Stevenson Street 40', 'tom_t10@email.com',
    '$2a$12$.wvgogPK7YxKCvXOhdEfMe69vmIIbXrtbnPE08Ic24vXBR2YRwwtu');
insert into clients(name, surname, phone, address, email, password) values(
    'Michel', 'Meclins', 1235607891, 'Clarkson Street 80', 'mclmcs@email.com',
    '$2a$12$1B6k3quEpOzUijv/XAxscODeXPEsfE645ObO0Aj8EgCCPPF0RJqMi');

insert into employeeInfo(name, surname, phone, email, salary, jobType) values(
    'Annabel', 'Wes', '1634007880', 'ablwes@email.com', 300, 0);
insert into employeeInfo(name, surname, phone, email, salary, jobType) values(
    'James', 'Lims', '1045001651', 'vgs165@email.com', 200, 1);
insert into employeeInfo(name, surname, phone, email, salary, jobType) values(
    'Agatha', 'Milkins', '1200067800', 'milkins25a@email.com', 250, 1);

insert into managers(employeeId) values(1);

insert into deliveryWorkers(employeeId) values(2);
insert into deliveryWorkers(employeeId) values(3);

insert into orders(clientId, managerId, deliveryWorkerId, cost, count, creationDatetime)
values(1, 1, 2, 100, 3, 1000000000);
insert into orders(clientId, managerId, deliveryWorkerId, cost, count, creationDatetime)
values(3, 1, 3, 101, 1, 1000519001);
insert into orders(clientId, managerId, deliveryWorkerId, cost, count, creationDatetime)
values(1, 1, 2, 102, 2, 1006000011);
insert into orders(clientId, managerId, deliveryWorkerId, cost, count, creationDatetime)
values(1, 1, 2, 123, 4, 1006540011);

insert into boughtComponents(componentId, orderId, clientId) values(1, 1, 1);
insert into boughtComponents(componentId, orderId, clientId) values(2, 1, 1);
insert into boughtComponents(componentId, orderId, clientId) values(3, 1, 1);
insert into boughtComponents(componentId, orderId, clientId) values(4, 2, 2);
insert into boughtComponents(componentId, orderId, clientId) values(5, 3, 3);
insert into boughtComponents(componentId, orderId, clientId) values(6, 3, 3);
insert into boughtComponents(componentId, orderId, clientId) values(7, 1, 1);
insert into boughtComponents(componentId, orderId, clientId) values(7, 2, 2);
insert into boughtComponents(componentId, orderId, clientId) values(7, 3, 3);

-- ---------------------------------

select * from components;
select * from employeeInfo;
select * from managers;
select * from clients;
select * from deliveryWorkers;
select * from orders;
select * from boughtComponents;

select * from boughtComponents where componentId = 1;
select * from components where cost > 3000;
select * from orders where count < 3;
select * from orders where count >=1;
select * from orders where count <= 3;
select * from components where count != 10;
select * from orders where completionDatetime is not null;
select * from orders where completionDatetime is null;
select * from components where cost between 1000 and 2000;
select * from components where componentId in (1, 2, 3);
select * from components where componentId not in (4, 5, 6);
select * from components where lower(description) like '%processor%';
select * from components where lower(name) like '%unlocked%';

-- -----------------------------

use db;

alter table clients add column isBanned int(1) after password;
# noinspection SqlWithoutWhere
describe clients;
update clients set isBanned = 0 where clientId = 2;
update clients set isBanned = 0;
alter table clients change isBanned banned int(1) not null default 0;
update clients set name = 'John' where clientId = 1;
select * from clients;

delete from employeeInfo where employeeId != 4;
alter table employeeInfo auto_increment = 1;
select * from employeeInfo;
select * from managers;
select * from deliveryWorkers;

delete from employeeInfo where employeeId = 1;
delete from managers where employeeId = 1;

delete from orders where orderId = 1 and clientId = 1;

select name from components order by type;
select name from components order by type desc;

alter table components change name name varchar(32);
alter table clients change email email varchar(32);
alter table employeeInfo change email email varchar(32);

-- -----------------------------

select name, surname from clients, orders where managerId = 1 group by name, surname;
select distinct clientId, count(*) as amount from orders group by clientId;
select sum(count) from orders where clientId = 1;

select orders.clientId, name, surname, count, cost from orders, clients where orders.clientId = clients.clientId;
select deliveryWorkers.employeeId, name, surname from deliveryWorkers, employeeInfo
where deliveryWorkers.employeeId = employeeInfo.employeeId;

select orderId, name, surname from orders, clients
where orders.clientId = clients.clientId and (deliveryWorkerId = 2 or deliveryWorkerId = 3);

select name, surname, cost from clients, orders where managerId = 1 and cost > 120;

select componentId, name from components where not exists
    (select componentId from boughtComponents where components.componentId = boughtComponents.componentId)
order by componentId;

select components.componentId, components.name from boughtComponents
    inner join components on components.componentId = boughtComponents.componentId order by componentId desc;

select components.componentId, components.name from components
    left join boughtComponents on components.componentId = boughtComponents.componentId order by components.componentId;

select components.componentId, components.name from components
    right join boughtComponents on components.componentId = boughtComponents.componentId order by components.componentId;

-- -------------------------------------

delimiter $$
create procedure _select(which int(1)) begin case which
    when 0 then select * from components;
    when 1 then select * from clients;
    when 2 then select * from orders;
    when 3 then select * from employeeInfo;
    when 4 then select * from managers;
    when 5 then select * from deliveryWorkers;
    when 6 then select * from boughtComponents;
end case; end$$
delimiter ;
call _select(1);

delimiter $$
create procedure countOrders() begin select count(*) from orders; end$$
delimiter ;
call countOrders();

delimiter $$
create function getEmployeeIdByEmail($email varchar(32)) returns int(6) reads sql data begin
    set @id := (select employeeId from employeeInfo where name = email = $email);
    return @id;
end$$
delimiter ;
select getEmployeeIdByEmail('ablwes@email.com');

delimiter $$
create procedure addManager(
    $name varchar(16),
    $surname varchar(16),
    $phone int(11),
    $email varchar(32),
    $salary int(4)
) begin
    insert into employeeInfo(name, surname, phone, email, salary, jobType)
    values($name, $surname, $phone, $email, $salary, 0);
    insert into managers(employeeId) values(getEmployeeIdByEmail($email));
end$$
delimiter ;
call addManager('tn', 'ts', 982267670, 'fedfte.e@rvgssfva.a', 100);
select * from employeeInfo, managers where employeeInfo.employeeId = managers.employeeId;

delimiter $$
create procedure addDeliveryWorker(
    $name varchar(16),
    $surname varchar(16),
    $phone int(11),
    $email varchar(32),
    $salary int(4)
) begin
    insert into employeeInfo(name, surname, phone, email, salary, jobType)
    values($name, $surname, $phone, $email, $salary, 1);
    insert into deliveryWorkers(employeeId) values(getEmployeeIdByEmail($email));
end$$
delimiter ;

delimiter $$
create trigger deleteEmployeeInfoAfterManagerDeleted after delete on managers for each row begin
    delete from employeeInfo where employeeInfo.employeeId = OLD.employeeId;
    update orders set orders.managerId = null where orders.managerId = OLD.employeeId;
end$$
delimiter ;

select * from employeeInfo, managers where employeeInfo.employeeId = managers.employeeId;
delete from managers where employeeId = 20;
select * from employeeInfo;

delimiter $$
create trigger deleteEmployeeInfoAfterDeliveryWorkerDeleted after delete on deliveryWorkers for each row begin
    delete from employeeInfo where employeeInfo.employeeId = OLD.employeeId;
    update orders set orders.deliveryWorkerId = null where orders.deliveryWorkerId = OLD.employeeId;
end$$
delimiter ;

create trigger deleteBoughtComponentsAfterOrderDeleted after delete on orders
    for each row delete from boughtComponents where boughtComponents.orderId = OLD.orderId;
create trigger deleteOrdersAfterClientDeleted after delete on clients
    for each row delete from orders where orders.clientId = OLD.clientId;
create trigger decreaseComponentCountOnBuyingIt after insert on boughtComponents
    for each row update components set count = count - 1 where components.componentId = NEW.componentId;
create trigger setJobTypeAfterManagerInserted after insert on managers
    for each row update employeeInfo set jobType = 0 where employeeId = NEW.employeeId;
create trigger setJobTypeAfterDeliveryWorkerInserted after insert on deliveryWorkers
    for each row update employeeInfo set jobType = 1 where employeeId = NEW.employeeId;

-- -------------------------------------------------------------------------

select name from clients; # (1) projection

select componentId from components where type = 0; # (2) selection

select orders.clientId, name, surname, count, cost from orders, clients where orders.clientId = clients.clientId; # (3) combination of 2 tables

select orderId, name, surname from orders, clients
    where orders.clientId = clients.clientId and (deliveryWorkerId = 2 or deliveryWorkerId = 3); # (4) union

select name, surname, cost from clients, orders where managerId = 1 and cost > 120; # (5) intersection

select componentId, name from components where not exists
    (select componentId from boughtComponents where components.componentId = boughtComponents.componentId)
	order by componentId; # (6) difference

select distinct clientId, count(*) as amount from orders group by clientId; # (7) projection, grouping

select components.componentId, components.name from boughtComponents
    inner join components on components.componentId = boughtComponents.componentId order by componentId desc; # (8) sort and join

select components.componentId, components.name from components
    left join boughtComponents on components.componentId = boughtComponents.componentId order by components.componentId;

select components.componentId, components.name from components
    right join boughtComponents on components.componentId = boughtComponents.componentId order by components.componentId;

select components.componentId, components.name from components
    left join boughtComponents on components.componentId = boughtComponents.componentId union
    select components.componentId, components.name from components
    right join boughtComponents on components.componentId = boughtComponents.componentId; # full pouter join


--

select components.componentId, components.name, boughtComponents.componentId from boughtComponents
    inner join components on components.componentId = boughtComponents.componentId
    order by components.componentId desc; # (8) sort and join

select components.componentId, components.name, boughtComponents.componentId from components
    left join boughtComponents on components.componentId = boughtComponents.componentId
    order by components.componentId;

select components.componentId, components.name, boughtComponents.componentId from components
    right join boughtComponents on components.componentId = boughtComponents.componentId
    order by components.componentId;