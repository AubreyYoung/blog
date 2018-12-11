# MongoDB常用命令

### db、show、use、help、dropdatabase

```
>db
test
> show dbs
admin    0.000GB
config   0.000GB
local    0.000GB
myNewDB  0.000GB
> use myNewdb
switched to db myNewdb
> db
myNewdb
> show logs
global
startupWarnings
> show users
> show profile
db.system.profile is empty
Use db.setProfilingLevel(2) will enable profiling
Use db.system.profile.find() to show raw profile entries
> use myNewDB
switched to db myNewDB
> db.dropDatabase()
{ "dropped" : "myNewDB", "ok" : 1 }
> use foo
switched to db foo
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
> db
foo
> db.runCommand( { dropDatabase: 1 } )
{ "ok" : 1 }
> show collections;
blog
```

### help

```
> help
        db.help()                    help on db methods
        db.mycoll.help()             help on collection methods
        sh.help()                    sharding helpers
        rs.help()                    replica set helpers
        help admin                   administrative help
        help connect                 connecting to a db help
        help keys                    key shortcuts
        help misc                    misc things to know
        help mr                      mapreduce

        show dbs                     show database names
        show collections             show collections in current database
        show users                   show users in current database
        show profile                 show most recent system.profile entries with time >= 1ms
        show logs                    show the accessible logger names
        show log [name]              prints out the last segment of log in memory, 'global' is default
        use <db_name>                set current database
        db.foo.find()                list objects in collection foo
        db.foo.find( { a : 1 } )     list objects in foo where a == 1
        it                           result of the last line evaluated; use to further iterate
        DBQuery.shellBatchSize = x   set default number of items to display on shell
        exit                         quit the mongo shell


> db.blog.find
function (query, fields, limit, skip, batchSize, options) {
    var cursor = new DBQuery(this._mongo,
                             this._db,
                             this,
                             this._fullName,
                             this._massageObject(query),
                             fields,
                             limit,
                             skip,
                             batchSize,
                             options || this.getQueryOptions());

    {
        const session = this.getDB().getSession();

        const readPreference = session._serverSession.client.getReadPreference(session);
        if (readPreference !== null) {
            cursor.readPref(readPreference.mode, readPreference.tags);
        }

        const readConcern = session._serverSession.client.getReadConcern(session);
        if (readConcern !== null) {
            cursor.readConcern(readConcern.level);
        }
    }

    return cursor;
}
> db.blog.update
function (query, obj, upsert, multi) {
    var parsed = this._parseUpdate(query, obj, upsert, multi);
    var query = parsed.query;
    var obj = parsed.obj;
    var upsert = parsed.upsert;
    var multi = parsed.multi;
    var wc = parsed.wc;
    var collation = parsed.collation;
    var arrayFilters = parsed.arrayFilters;

    var result = undefined;
    var startTime =
        (typeof(_verboseShell) === 'undefined' || !_verboseShell) ? 0 : new Date().getTime();

    if (this.getMongo().writeMode() != "legacy") {
        var bulk = this.initializeOrderedBulkOp();
        var updateOp = bulk.find(query);

        if (upsert) {
            updateOp = updateOp.upsert();
        }

        if (collation) {
            updateOp.collation(collation);
        }

        if (arrayFilters) {
            updateOp.arrayFilters(arrayFilters);
        }

        if (multi) {
            updateOp.update(obj);
        } else {
            updateOp.updateOne(obj);
        }

        try {
            result = bulk.execute(wc).toSingleResult();
        } catch (ex) {
            if (ex instanceof BulkWriteError) {
                result = ex.toSingleResult();
            } else if (ex instanceof WriteCommandError) {
                result = ex;
            } else {
                // Other exceptions thrown
                throw ex;
            }
        }
    } else {
        if (collation) {
            throw new Error("collation requires use of write commands");
        }

        if (arrayFilters) {
            throw new Error("arrayFilters requires use of write commands");
        }

        this.getMongo().update(this._fullName, query, obj, upsert, multi);

        // Enforce write concern, if required
        if (wc) {
            result = this.runCommand("getLastError", wc instanceof WriteConcern ? wc.toJSON() : wc);
        }
    }

    this._printExtraInfo("Updated", startTime);
    return result;
}
```

### CRUD

```
> use foo
switched to db foo
> show dbs
admin   0.000GB
config  0.000GB
local   0.000GB
> db
foo
> db.runCommand( { dropDatabase: 1 } )
{ "ok" : 1 }
> post = {"title":"My Blog Post", "content":"Here's my blog post.", "date":new Date()}
{
        "title" : "My Blog Post",
        "content" : "Here's my blog post.",
        "date" : ISODate("2018-11-20T01:40:24.959Z")
}
> use blog
switched to db blog
> db
blog
> db.blog.insert(post)
WriteResult({ "nInserted" : 1 })
> db.blog.find()
{ "_id" : ObjectId("5bf366271a91bd3959b0bf04"), "title" : "My Blog Post", "content" : "Here's my blog post.", "date" : ISODate("2018-11-20T01:40:24.959Z") }
> show dbs
admin   0.000GB
blog    0.000GB
config  0.000GB
local   0.000GB
> db.blog.findOne()
{
        "_id" : ObjectId("5bf366271a91bd3959b0bf04"),
        "title" : "My Blog Post",
        "content" : "Here's my blog post.",
        "date" : ISODate("2018-11-20T01:40:24.959Z")
}
> post.comments=[]
[ ]
> db.blog.update({title:"My Blog Post"},post)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.blog.find()
{ "_id" : ObjectId("5bf366271a91bd3959b0bf04"), "title" : "My Blog Post", "content" : "Here's my blog post.", "date" : ISODate("2018-11-20T01:40:24.959Z"), "comments" : [ ] }

> show collections;
blog
> db.blog.remove({title:"My Blog POST"})
WriteResult({ "nRemoved" : 0 })
> show collections;
blog
> db.blog.find()
{ "_id" : ObjectId("5bf366271a91bd3959b0bf04"), "title" : "My Blog Post", "content" : "Here's my blog post.", "date" : ISODate("2018-11-20T01:40:24.959Z"), "comments" : [ ] }
> db.blog.remove({title:"My Blog Post"})
WriteResult({ "nRemoved" : 1 })
> db.blog.find()
```

