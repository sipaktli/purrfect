**purrfect** is a simple bundle of scripts for lightweight system administration.

SysAdmin tools usually target large-r production environments,
and come with "client" daemons...
and require open ports...
and dependencies...
and client/server thingies going on that require admin work too...
... and lots of bells and whistles that you probably do not need.
Or want.

purrfect means to be portable, easy to configure and setup and hack:
One single cron line or one .timer to initiate and schedule purrfect.
One single config to rule it all, and in automation, bind it.

Target audience:
- You just want to manage your home systems.
- You are not a power user.
- You are yes a power user, but KISS!
- You want to manage your one/two server(s) from git (push .conf)

---

To do:

- I am currently working on merging the scripts and testing consistency. 

Over the time I made several, very distinct versions of the project and its scripts. It was more of an project of experiments, than a product meant for deployment. - I know, not very agile.

But I think it is about time I make it production-ready.

- Next version will include an api interface to interact with purrfect, so that it can interface with orchestrators. Scaling stuff.

- Next version after that: rewrite in golang

