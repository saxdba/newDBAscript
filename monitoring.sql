--dbcc opentran('RavenPack')
--dbcc sqlperf(logspace)
--sp_helpdb 'tempdb'
--EXEC sp_WhoIsActive @sort_order = '[session_id]', @filter_type='login',@filter='SACCAP\RohitKu'--, @delta_interval=5--, @delta_interval=15--@output_column_list='[percent_complete][%]'
--EXEC sp_WhoIsActive @sort_order = '[session_id]', @get_plans=1, @get_outer_command=1, @show_sleeping_spids=0--,@get_additional_info=2--, @filter_type='login', @filter='SACCAP\svc_prd_suzh'
--kill 249 
--exec sp_who2 875
/*select LoggedDateTime,spid,login_time,last_batch,status,hostname,p_dbid,loginame,cpu_diff,io_diff,blocked,lastwaittype,sql_stmt,sql_batch from AgioAdmin.dbo.SACsysprocessesDiff
where LoggedDateTime > '2022-098-14 02:45:02.187' and LoggedDateTime < '2022-08-18 03:00:02.187' and status <>'background   */
--DBCC INPUTBUFFER(70)
--select name,log_reuse_wait_desc from sys.databases where name='sacpanoapps'
--select DISTINCT(req_transactionUOW) from sys.syslockinfo where req_spid=-2
--select *  from sys.syslockinfo where req_spid=-2
--kill '16579F54-7891-4AEB-81D3-F5E4E2DC7599'
--select * from sys.dm_exec_requests where session_id>50
--SELECT * FROM OPENDATASOURCE('SQLNCLI','Data Source=SACPWDB;Integrated Security=SSPI').PW.dbo.FactDatabaseFile_Worktable;
SELECT
             es.session_id,
                     er.start_time,
             CONVERT(varchar(12), DATEDIFF(second, er.start_time, GETDATE()) / 3600) + ':' +
       RIGHT('0' + CONVERT(varchar(2), (DATEDIFF(second, er.start_time, GETDATE()) % 3600) / 60), 2) + ':' +
       RIGHT('0' + CONVERT(varchar(2), DATEDIFF(second, er.start_time, GETDATE()) % 60), 2) AS [Duratin_hh:mm:ss],
(deqmg.requested_memory_kb / 1024.) requested_memory_mb,
               (deqmg.granted_memory_kb / 1024.) granted_memory_mb,
(deqmg.wait_time_ms / 1000.) wait_time_s,
deqmg.dop,
             er.status,
              er.command,
             es.login_name,
             DB_NAME(er.database_id) as database_name,
             --es.host_name,
                     OBJECT_NAME(st.objectid, er.database_id) as object_name,
             es.program_name,
                     er.percent_complete,
             er.blocking_session_id,
                     er.logical_reads,
             er.reads ,
             er.writes,
             er.cpu_time,
             er.wait_type,
          
                       CONVERT(VARCHAR, DATEADD(ms, er.wait_time, 0), 8) AS 'wait_time',
                     
CONVERT(varchar, (er.total_elapsed_time/1000 / 86400))+ 'd ' +
     CONVERT(VARCHAR, DATEADD(ms, er.total_elapsed_time, 0), 8)   AS 'elapsed_time',
             er.last_wait_type,
              er.wait_resource,
 
    es.last_request_end_time
      , CAST((
            '<?query --  ' + CHAR(13) + CHAR(13) + Substring(st.TEXT, (er.statement_start_offset / 2) + 1, (
                    (
                        CASE er.statement_end_offset
                            WHEN - 1
                                THEN Datalength(st.TEXT)
                            ELSE er.statement_end_offset
                            END - er.statement_start_offset
                        ) / 2
                    ) + 1) + CHAR(13) + CHAR(13) + '--?>'
            ) AS XML) AS 'query_text'
,ph.query_plan
FROM sys.dm_exec_connections ec
LEFT OUTER JOIN sys.dm_exec_sessions es ON ec.session_id = es.session_id
LEFT OUTER JOIN sys.dm_exec_query_memory_grants  deqmg on deqmg.session_id=ec.session_id
LEFT OUTER JOIN sys.dm_exec_requests er ON ec.connection_id = er.connection_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) ph
WHERE ec.session_id <> @@SPID and ec.session_id  > 50
and er.status not in ('sleeping','dormant')
--and (deqmg.granted_memory_kb / 1024)>10000
--and OBJECT_NAME(st.objectid, er.database_id) like '%usp_UpdatefactPrice%'
--order by database_name
--and er.database_id=DB_ID('IS_Reports')
--and es.program_name not like 'SQLAgent%'
--and es.login_name not like 'NT AUTHO%'
ORDER BY
es.session_id
--start_time
 --[Duratin_hh:mm:ss] desc
 
