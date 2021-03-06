mg.write('HTTP/1.0 200 OK\r\n', 'Content-Type: text/plain\r\n', '\r\n')
mg.write(os.date("%A"))

-- for k,v in pairs(_G) do mg.write(k, '\n') end

-- Open database
local db = sqlite3.open('requests.db')

-- Setup a trace callback, to show SQL statements we'll be executing.
-- db:trace(function(data, sql) mg.write('Executing: ', sql: '\n') end, nil)

-- Create a table if it is not created already
db:exec([[
  CREATE TABLE IF NOT EXISTS requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp NOT NULL,
    method NOT NULL,
    uri NOT NULL,
    addr
  );
]])


-- Add entry about this request
local stmt = db:prepare(
  'INSERT INTO requests VALUES(NULL, datetime("now"), ?, ?, ?);');
stmt:bind_values(mg.request_info.request_method,
                 mg.request_info.uri,
                 mg.request_info.remote_port)
stmt:step()
stmt:finalize()

-- Show all previous records
mg.write('Previous requests:\n')
stmt = db:prepare('SELECT * FROM requests ORDER BY id DESC;')
while stmt:step() == sqlite3.ROW do
  local v = stmt:get_values()
  mg.write(v[1] .. ' ' .. v[2] .. ' ' .. v[3] .. ' '
        .. v[4] .. ' ' .. v[5] .. '\n')
end

-- Close database
db:close()
