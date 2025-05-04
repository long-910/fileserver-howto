FROM filebrowser/filebrowser:s6

COPY config/filebrowser.db /database/filebrowser.db
COPY setup.sh /setup.sh
RUN chmod +x /setup.sh
CMD ["/setup.sh"]
