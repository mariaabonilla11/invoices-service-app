class AddInvoicesSequenceAndTrigger < ActiveRecord::Migration[7.2]
  def up
    # Create the sequence for INVOICES table (Oracle uses sequences for auto-increment)
    execute <<-SQL
      CREATE SEQUENCE INVOICES_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE
    SQL

    # Create a trigger to auto-assign the next sequence value to the ID column
    execute <<-SQL
      CREATE OR REPLACE TRIGGER TRG_INVOICES_BI
      BEFORE INSERT ON INVOICES
      FOR EACH ROW
      WHEN (new.id IS NULL)
      BEGIN
        SELECT INVOICES_SEQ.NEXTVAL INTO :NEW.id FROM DUAL;
      END;
    SQL
  end

  def down
    # Drop the trigger and sequence when rolling back
    execute "DROP TRIGGER TRG_INVOICES_BI"
    execute "DROP SEQUENCE INVOICES_SEQ"
  end
end
