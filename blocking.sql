/*
Blocking queries shown in Group.
*/

WITH cteBL (session_id, blocking_these) AS 
(SELECT s.session_id, blocking_these = x.blocking_these FROM sys.dm_exec_sessions s 
CROSS APPLY    (SELECT isnull(convert(varchar(6), er.session_id),'') + ', '  
                FROM sys.dm_exec_requests as er
                WHERE er.blocking_session_id = isnull(s.session_id ,0)
                AND er.blocking_session_id <> 0
                FOR XML PATH('') ) AS x (blocking_these)
)
SELECT 
s.login_time,
s.session_id, 
CASE WHEN r.blocking_session_id=0 THEN 'Root Blocker' ELSE CAST (r.blocking_session_id AS VARCHAR) END AS Blocked_By, 
bl.blocking_these,
s.host_name,
DB_NAME(r.database_id) AS Database_Name,
s.program_name,
s.nt_user_name,
r.status,
r.last_wait_type,
(r.wait_time/1000) AS Current_Wait_Sec,
--r.open_transaction_count,
r.command,
r.wait_resource,

--r.wait_time,
--r.granted_query_memory, 
ib.event_info As Current_Text,
t.text As Batch_Text
--,* This can be enabled to find all columns from other DMVs. Use it to get more details in result set.
FROM sys.dm_exec_sessions s 
LEFT OUTER JOIN sys.dm_exec_requests r on r.session_id = s.session_id
INNER JOIN cteBL as bl on s.session_id = bl.session_id
OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) t
OUTER APPLY sys.dm_exec_input_buffer(s.session_id, NULL) AS ib
WHERE blocking_these is not null or r.blocking_session_id > 0
ORDER BY len(bl.blocking_these) desc, r.blocking_session_id desc, r.session_id;

