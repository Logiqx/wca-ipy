/*
    Script:   Determine time bands
    Created:  2019-08-31
    Author:   Michael George / 2015GEOR02

    Purpose:  Determine time bands for "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    The output of this is inspected manually and converted into  SQL
*/

SET @eventId = '444';

SELECT modified_best, MIN(shift), MAX(shift), MIN(best), MAX(best), MIN(min_best), MAX(max_best), COUNT(*) AS numPersons
FROM
(
	SELECT
		best,
		@pd := 1 / (SQRT(2 * PI()) * theta * best) * EXP(-0.5 * (POWER((LN(best) - mu) / theta, 2))) AS pd,
        @shift := 15 - FLOOR(LOG2(65536 * @pd / max_pd)) +
        (
			CASE
				WHEN r.eventId IN ('222') THEN 2           -- 0.04s
				WHEN r.eventId IN ('333', 'pyram') THEN 3      -- 0.08s
				WHEN r.eventId IN ('skewb') THEN 4         -- 0.16s
				WHEN r.eventId IN ('333oh') THEN 5         -- 0.32s
				WHEN r.eventId IN ('444', 'clock') THEN 6     -- 0.64s
				WHEN r.eventId IN ('555', 'sq1') THEN 7          -- 1.28s
				WHEN r.eventId IN ('minx', '333fm') THEN 8      -- 2.56s
				WHEN r.eventId IN ('666') THEN 9                -- 5.12s
				WHEN r.eventId IN ('777', '333ft') THEN 10      -- 10.24s
				WHEN r.eventId IN ('333bf') THEN 10             -- 20.48s
				WHEN r.eventId IN ('444bf') THEN 15
				WHEN r.eventId IN ('555bf') THEN 16
                ELSE 1
			END
        ) AS shift,
        @mask := (1 << @shift) - 1 AS mask,
		IF(best < turning_point, best & ~@mask, best | @mask) AS modified_best,
		best & ~@mask AS min_best,
		best | @mask AS max_best
	FROM RanksSingle AS r
    JOIN
    (
        SELECT eventId, mu, theta, @turning_point := EXP(mu - theta * theta) AS turning_point,
			1 / (SQRT(2 * PI()) * theta * @turning_point) * EXP(-0.5 * (POWER((LN(@turning_point) - mu) / theta, 2))) AS max_pd
		FROM
        (
			SELECT eventId, @mu := AVG(LN(best)) AS mu, @theta := STDDEV(LN(best)) AS theta
			FROM RanksSingle
			GROUP BY eventId
		) AS t3
    ) AS t2 ON t2.eventId = r.eventId
	WHERE r.eventId = @eventId
) AS t1
GROUP BY modified_best;

SELECT modified_best, MIN(shift), MAX(shift), MIN(best), MAX(best), MIN(min_best), MAX(max_best), COUNT(*) AS numPersons
FROM
(
	SELECT
		best,
		@pd := 1 / (SQRT(2 * PI()) * theta * best) * EXP(-0.5 * (POWER((LN(best) - mu) / theta, 2))) AS pd,
        @shift := 15 - FLOOR(LOG2(65536 * @pd / max_pd)) +
        (
			CASE
				WHEN r.eventId IN ('222') THEN 2
				WHEN r.eventId IN ('333', 'pyram') THEN 3
				WHEN r.eventId IN ('skewb') THEN 4
				WHEN r.eventId IN ('333oh') THEN 5
				WHEN r.eventId IN ('444', 'clock') THEN 6
				WHEN r.eventId IN ('555', 'sq1') THEN 7
				WHEN r.eventId IN ('minx', '333fm') THEN 8
				WHEN r.eventId IN ('666') THEN 9
				WHEN r.eventId IN ('777', '333ft') THEN 10
				WHEN r.eventId IN ('333bf') THEN 11
				WHEN r.eventId IN ('444bf') THEN 15
				WHEN r.eventId IN ('555bf') THEN 16
                ELSE 1
			END
        ) AS shift,
        @mask := (1 << @shift) - 1 AS mask,
		IF(best < turning_point, best & ~@mask, best | @mask) AS modified_best,
		best & ~@mask AS min_best,
		best | @mask AS max_best
	FROM RanksAverage AS r
    JOIN
    (
        SELECT eventId, mu, theta, @turning_point := EXP(mu - theta * theta) AS turning_point,
			1 / (SQRT(2 * PI()) * theta * @turning_point) * EXP(-0.5 * (POWER((LN(@turning_point) - mu) / theta, 2))) AS max_pd
		FROM
        (
			SELECT eventId, @mu := AVG(LN(best)) AS mu, @theta := STDDEV(LN(best)) AS theta
			FROM RanksAverage
			GROUP BY eventId
		) AS t3
    ) AS t2 ON t2.eventId = r.eventId
	WHERE r.eventId = @eventId
) AS t1
GROUP BY modified_best;
