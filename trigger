CREATE TRIGGER trg_PreventDoubleClaim
ON slogsall
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Prevent duplicate claims within 12 hours
    IF EXISTS (
        SELECT 1
        FROM slogsall s
        JOIN inserted i ON s.id = i.id
        WHERE s.uq_timestamp >= DATEADD(HOUR, -12, i.uq_timestamp)
          AND s.uq_timestamp < i.uq_timestamp
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('You have already claimed your meal stub within the last 12 hours.', 16, 1);
    END
END;
