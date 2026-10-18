# Failure + recovery verification

## Purpose

Test automatic rollback after an unhealthy application deployment. Restored deleted demo data from an SQLite backup.

## Rollback

The controlled failure image was built with `deploy/recovery/Dockerfile.unhealthy`. It inherited the working application image but replaced the startup command with a sleeping Python process. The container ran without
starting the web server, causing the existing health check to fail.

That fixture was manually published for this exercise. The normal
deployment workflow's approved revision remains unchanged.

### Release identities

Working image: `sha256:fa64de4f4c45d263c28f9a2f7c7423bc1fa10cc35aa38376bb8d2d99bf54af08`

Unhealthy candidate: `sha256:65e80de791250a538abd4abf06d4b4a7ace0432044c29d0be6f3350072a877bd`

Both images were stored in the VulnLab ECR repository.

### Evidence

- Instance: i-0c1ef48c9959fa2eb
- SSM document: vulnlab-deploy; version 2
- Command ID: 216e7dc4-421b-468d-8e07-fa55e0ded310
- Started: 2026-10-10T23:47:58.409Z
- Finished: 2026-10-10T23:49:15.409Z
- SSM-reported elapsed time: PT1M17.648S
- Final command status: Failed
- Exit code: 1

The output shows:

```text
Deployment failed. Attempting the previous release.
{"status":"ok"}
Redis reachable
Previous release restored.
```

The failed status correctly reports candidate rejection. Further inspection confirmed that the working image was running, with both containers healthy.

The 77.648-second duration covers the complete deployment and
rollback operation.

## Database backup and restore

A consistent snapshot was created using Python's SQLite backup API.

Backup locations on EC2:

- `/app/instance/backups/card11-before-recovery.sqlite` inside the application data volume.
- `/var/backups/vulnlab/card11-before-recovery.sqlite` outside the application volume, owned by root with mode 0600.

Both copies had SHA-256 `ceaa67c9e5b9a29c48aead84350fa8abe79d0b5644842e02207b4c3c9ef073ad`. The snapshot passed the SQLite integrity checking and contained four
notes, including note ID 4 titled `Card 11 recovery marker`.

### Data loss test

Only note ID 4 was deleted with the matching title through a
parameterized SQL statement.

- Live note count fell from four to three
- Exact recovery marker count fell from one to zero
- Note disappeared from the app itself

### Restoration procedure

- Stopped the application container, closing database connections
- Read the host backup into a temporary Compose helper container
- Verified the backup checksum + SQLite integrity
- Preserved the prerestore database
- Restored the full snapshot
- Checked restored database integrity, compared every user and note record against the backup
- Restarted the application while verifying the container and HTTP health.
- Confirmed the recovered note appeared in the browser

Results:

- Restore verified
- Integrity: ok
- Restored notes: 4
- Recovery markers: 1
- User and note records match the backup.

The manually timed restore window was 37 seconds which included time
between commands.

## Limitations

- Application rollback does not reverse database changes or migrations.
- These tests cover an unavailable application server and a single
  data deletion case, not every possible failure.

## Follow up

- Completed: exported and verified a database backup off the host. A recovery archive was used to restore the application onto a replacement EC2 host; see [Host rebuild verification](rebuild.md).
