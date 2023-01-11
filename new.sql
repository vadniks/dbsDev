
-- DDL ---------------------------------------------------

drop database movies;
create database movies;
use movies;

# noinspection SpellCheckingInspection
create table actor(
    act_id int unsigned not null auto_increment,
    act_fname tinytext not null, -- firstName I guess
    act_lname tinytext not null, -- and lastName
    act_genger enum('male', 'female') not null,
    primary key (act_id),
    index (act_fname(63), act_lname(63)) -- 63 is max, required
);

# noinspection SpellCheckingInspection
create table director(
    dir_id int unsigned not null auto_increment,
    dir_fname tinytext not null,
    dir_lname tinytext not null,
    primary key (dir_id),
    index(dir_fname(63), dir_lname(63))
);

create table movie(
    mov_id int unsigned not null auto_increment,
    mov_title mediumtext not null,
    mov_year smallint unsigned not null,
    mov_time smallint unsigned not null,
    mov_lang enum('ru', 'en', 'fr', 'de', 'ch', 'jp'/*...*/) not null,
    mov_dt_rel date null, -- date of release, null if it hasn't been not released yet
    mov_rel_country tinytext not null,
    primary key (mov_id)
);
create unique index x_mov_title on movie(mov_title(255));

create table genres(
    gen_id int unsigned not null auto_increment,
    gen_title tinytext not null,
    primary key (gen_id)
);
create unique index x_gen_title on genres(gen_title(63));

create table reviewer(
    rev_id int unsigned not null auto_increment,
    rev_name tinytext not null,
    primary key (rev_id)
);
create unique index x_rev_name on reviewer(rev_name(63));

-- end of parent entities

create table movie_direction( -- many to many relation
    dir_id int unsigned not null, -- not unique so movie might have several directors
    mov_id int unsigned not null,
    foreign key (dir_id) references director(dir_id) on update restrict on delete restrict,
    foreign key (mov_id) references movie(mov_id) on update restrict on delete restrict,
    primary key (dir_id, mov_id)
    -- constraint unique index mdx(dir_id, mov_id) -- to ensure uniqueness of the composite key,
    -- not necessary as primary key does the same in this case
);

create table movie_cast( -- many to many relation
    act_id int unsigned not null,
    mov_id int unsigned not null,
    role tinytext not null,
    foreign key (act_id) references actor(act_id) on update cascade on delete restrict,
    foreign key (mov_id) references movie(mov_id) on update cascade on delete restrict,
    primary key (act_id, mov_id)
);

create table movie_genres( -- many to many relation
    mov_id int unsigned not null,
    gen_id int unsigned not null,
    foreign key (mov_id) references movie(mov_id) on update cascade on delete restrict,
    foreign key (gen_id) references genres(gen_id) on update cascade on delete restrict,
    primary key (mov_id, gen_id)
);

create table rating( -- many to many relation
    mov_id int unsigned not null,
    rev_id int unsigned not null,
    rev_stars tinyint unsigned not null,
    num_o_ratings int unsigned not null, -- purpose is unknown
    foreign key (mov_id) references movie(mov_id) on update cascade on delete restrict,
    foreign key (rev_id) references reviewer(rev_id) on update cascade on delete restrict,
    primary key (mov_id, rev_id)
);

-- triggers

create trigger deleteDirectorAfterMovieDirectionDeleted after delete on movie_direction for each row
begin delete from director where dir_id = old.dir_id; end;

create trigger deleteReviewerAfterRatingDeleted after delete on rating for each row
begin delete from reviewer where rev_id = old.rev_id; end;

create trigger insertGenreBeforeCorrespondingProxyInserted before insert on movie_genres for each row
begin insert into genres(gen_id, gen_title) values(new.gen_id, concat('genre of ', new.mov_id)); end;

-- functions/procedures with DML

set autocommit = off;

delimiter $$ -- mysql workbench support, unnecessary in DataGrip, unknown in console
create procedure insertBritainMovie(
    title tinytext, year smallint unsigned, time smallint unsigned, released date
) begin
    insert into movie(mov_title, mov_year, mov_time, mov_lang, mov_dt_rel, mov_rel_country)
    values (title, year, time, 'en', released, 'uk');
end$$
delimiter ;

delimiter $$
create procedure insertMovies() begin start transaction;
    set @i = 1;
    while @i <= 10 do
        call insertBritainMovie(cast(@i as char), @i, @i, curdate());
        set @i = @i + 1;
    end while;
commit; end $$
delimiter ;

delimiter $$
create function doubleChar(chr char) returns char(2) deterministic begin return concat(chr, chr); end $$
delimiter ;

delimiter $$
create procedure insertPeople() begin start transaction;
    set @i = 1, @j = 1;
    while @i <= 10 do
        set @j = cast(@i - 1 as char);

        insert into actor(act_fname, act_lname, act_genger)
        values(@j, doubleChar(@j), if(@i % 2 = 0, 'male', 'female'));

        insert into director(dir_fname, dir_lname) values(concat('_', @j), concat('_', doubleChar(@j)));
        insert into reviewer(rev_name) values(concat('@', @j));

        set @i = @i + 1;
    end while;
commit; end $$
delimiter ;

create procedure insertProxies() begin start transaction;
    set @i = 1, @uint32max = 4294967295;
    while @i <= 5 do
        insert into movie_direction(dir_id, mov_id) values(@i, @i);
        insert into movie_cast(act_id, mov_id, role) values(@i, @i, 'whatever');
        insert into movie_genres(mov_id, gen_id) values (@i, @i);
        insert into rating(mov_id, rev_id, rev_stars, num_o_ratings) values(@i, @i, @i, @uint32max - @i);
        set @i = @i + 1;
    end while;
commit; end;

delimiter $$
create function humaneType(name mediumtext) returns tinytext deterministic begin return case
    when name like '\_%' then 'director'
    when name like '@%' then 'reviewer'
    else 'actor'
end; end $$
delimiter ;

# drop procedure insertActorToAllMovies;
create procedure insertActorToAllMovies(
    in firstName tinytext, in lastName tinytext, in gender tinytext, out count int unsigned
) begin start transaction;
    if firstName != '-' then
        signal sqlstate '45000' set message_text = 'wrong first name'; -- throw an error
    end if;

    insert into actor(act_fname, act_lname, act_genger) values(firstName, lastName, gender);
    set @actorId = last_insert_id();

    set @i = 0;
    set @count = (select count(*) from movie);

    set @offset = 1;
    prepare stm from 'select mov_id from movie order by mov_id asc limit 1 offset ? into @movId';

    while @i < @count do
        set @offset = @i;
        execute stm using @offset;

        insert into movie_cast(act_id, mov_id, role)
        values(@actorId, @movId, 'ubiquitous');

        set @i = @i + 1;
    end while;

    deallocate prepare stm;
commit; end;

-- views

create view people as -- defined here cuz it uses a user defined function, cannot be updated
    select act_id as id, act_fname as name, humaneType(act_fname) from actor
    union
    select dir_id, dir_fname, humaneType(dir_fname) from director
    union
    select rev_id, rev_name, humaneType(rev_name) from reviewer;

-- DQL

call insertMovies();
select * from movie;

call insertPeople();
select * from actor;
select * from director;
select * from reviewer;

select * from people;

call insertProxies();
select * from movie_direction;
select * from movie_cast;
select * from movie_genres;
select * from rating;

select dir_fname from director
right join movie_direction on movie_direction.mov_id = director.dir_id
join movie on movie.mov_id = movie_direction.mov_id;

select act_fname, mov_id from actor
join movie_cast mc on actor.act_id = mc.act_id
where mov_id in (select movie.mov_id from movie);

select mov_title, floor(avg(rev_stars)) from rating
join movie m on rating.mov_id = m.mov_id
group by mov_title;

select movie.mov_id, r.rev_id from movie
join rating on movie.mov_id = rating.mov_id
join reviewer r on rating.rev_id = r.rev_id;

select gen_id from genres where gen_id in
(select gen_id from movie_genres where mov_id in (select mov_id from movie));

select movie.mov_id from movie
left join rating r on movie.mov_id = r.mov_id
where r.rev_stars is null;

select actor.act_id from actor
left join movie_cast mc on actor.act_id = mc.act_id
left join movie m on mc.mov_id = m.mov_id
left join rating r on m.mov_id = r.mov_id
where rev_stars is null;

select * from actor;
select * from movie_cast;
call insertActorToAllMovies('-', '*', 'male', @xcount);
select @xcount;

select act_fname, role, count(m.mov_id) as count from actor
join movie_cast mc on actor.act_id = mc.act_id
join movie m on m.mov_id = mc.mov_id
group by act_fname, role
having count = (select count(*) from movie);
