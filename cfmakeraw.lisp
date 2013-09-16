(cl:in-package :sb-posix)
(declaim (notinline cfsetospeed cfsetospeed cfmakeraw))
(sb-ext:without-package-locks
  (export '(cfmakeraw) :sb-posix))
(sb-ext:without-package-locks
  (export '(cfsetispeed) :sb-posix)
  (declaim (inline cfsetispeed))
  (defun cfsetispeed (speed &optional termios)
   (declare (type (or null termios) termios))
   (with-alien-termios a-termios ()
     (termios-to-alien termios a-termios)
     (let ((r (alien-funcall
               (extern-alien "cfsetispeed"
                             (function int (* alien-termios) speed-t))
               a-termios
               speed)))
       (when (minusp r)
         (syscall-error 'cfsetispeed))
       (setf termios (alien-to-termios a-termios termios))))
   termios))
(sb-ext:without-package-locks
  (defun cfsetospeed (speed &optional termios)
   (declare (type (or null termios) termios))
   (with-alien-termios a-termios ()
     (termios-to-alien termios a-termios)
     (let ((r (alien-funcall
               (extern-alien "cfsetospeed"
                             (function int (* alien-termios) speed-t))
               a-termios
               speed)))
       (when (minusp r)
         (syscall-error 'cfsetospeed))
       (setf termios (alien-to-termios a-termios termios))))
   termios))
(sb-ext:without-package-locks
  (export '(cfmakeraw) :sb-posix)
  (defun cfmakeraw (termios)
    "Set raw mode"
    (declare (type termios termios))
    (with-alien-termios a-termios ()
      (termios-to-alien termios a-termios)
      (alien-funcall
       (extern-alien "cfmakeraw"
		     (function void (* alien-termios)))
       a-termios)
      (setf termios (alien-to-termios a-termios termios)))
    termios))
