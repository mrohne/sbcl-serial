(cl:in-package :sb-posix)
(declaim (notinline posix-openpt grantpt unlockpt ptsname))
(sb-ext:without-package-locks
  (export '(posix-openpt) :sb-posix)
  (define-call "posix_openpt" int minusp (flags int)))
(sb-ext:without-package-locks
  (export '(grantpt) :sb-posix)
  (define-call "grantpt" int minusp (fd file-descriptor)))
(sb-ext:without-package-locks
  (export '(unlockpt) :sb-posix)
  (define-call "unlockpt" int minusp (fd file-descriptor)))
(sb-ext:without-package-locks
  (export '(ptsname) :sb-posix)
  (define-call "ptsname" c-string null (fd file-descriptor)))


