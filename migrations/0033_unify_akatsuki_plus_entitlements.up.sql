-- Deploy the payments-service and admin-panel AKATSUKI+ writers before this migration.
-- Subscription entitlement is the pair of legacy donor (4) and premium (8388608) bits.

-- A future expiry without membership bits must not restore revoked benefits.
UPDATE users
SET donor_expire = 0, can_custom_badge = 0
WHERE (privileges & 8388612) = 0 AND donor_expire > UNIX_TIMESTAMP();

DELETE ub FROM user_badges ub
INNER JOIN users u ON u.id = ub.user
WHERE ub.badge IN (36, 59)
  AND ((u.privileges & 8388612) != 8388612 OR u.donor_expire <= UNIX_TIMESTAMP());

-- Replace active legacy badges in place without using another UI badge slot.
UPDATE user_badges legacy_badge
INNER JOIN users u ON u.id = legacy_badge.user
LEFT JOIN user_badges member_badge ON member_badge.user = u.id AND member_badge.badge = 59
LEFT JOIN user_badges earlier_badge ON earlier_badge.user = u.id
    AND earlier_badge.badge = 36 AND earlier_badge.id < legacy_badge.id
SET legacy_badge.badge = 59
WHERE legacy_badge.badge = 36
  AND (u.privileges & 8388612) = 8388612
  AND u.donor_expire > UNIX_TIMESTAMP()
  AND member_badge.id IS NULL
  AND earlier_badge.id IS NULL;

DELETE FROM user_badges WHERE badge = 36;

-- Add missing membership badges only when an ordinary member has a free UI slot.
-- Staff presets may have complimentary benefits without a membership badge; preserve that policy.
INSERT INTO user_badges (user, badge)
SELECT u.id, 59
FROM users u
WHERE u.privileges = 8388615
  AND u.donor_expire > UNIX_TIMESTAMP()
  AND (SELECT COUNT(*) FROM user_badges slots WHERE slots.user = u.id) < 6
  AND NOT EXISTS (
      SELECT 1 FROM user_badges member_badge WHERE member_badge.user = u.id AND member_badge.badge = 59
  );

UPDATE users
SET can_custom_badge = ((privileges & 8388612) = 8388612 AND donor_expire > UNIX_TIMESTAMP());

-- Users store privilege masks, rather than references to preset IDs.
DELETE FROM privileges_groups WHERE name = 'Donor' AND privileges = 7;
UPDATE privileges_groups SET name = 'AKATSUKI+' WHERE name = 'Premium' AND privileges = 8388615;

ALTER TABLE users
ADD CONSTRAINT users_subscription_bits_paired CHECK ((privileges & 8388612) IN (0, 8388612));

ALTER TABLE privileges_groups
ADD CONSTRAINT privilege_groups_subscription_bits_paired CHECK ((privileges & 8388612) IN (0, 8388612));
