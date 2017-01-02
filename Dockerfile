FROM ruby:2.4-onbuild

CMD ["bundle", "exec", "puma", "-t", "8:12", "-w", "2", "-p", "80", "-e", "production"]

EXPOSE 80
