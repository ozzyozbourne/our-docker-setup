FROM rclone/rclone:1.75.2 AS rclone

FROM postgres:18.6-trixie
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone
COPY backup.sh /usr/local/bin/backup.sh
CMD ["/usr/local/bin/backup.sh"]
