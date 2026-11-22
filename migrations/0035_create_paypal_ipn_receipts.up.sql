-- Claims for new verified IPNs are inserted in the same transaction as the grant.
-- Legacy notifications are still checked to recognize deliveries made before rollout.
CREATE TABLE IF NOT EXISTS paypal_ipn_receipts (
  transaction_id varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  PRIMARY KEY (transaction_id)
) ENGINE=InnoDB;
