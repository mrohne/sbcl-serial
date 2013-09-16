(in-package :serial-port)

(defmacro nboole (op place bits &environment env)
  "Perform in-place (BOOLE OP PLACE BITS)"
   (multiple-value-bind (tmps vals new setter getter)
       (get-setf-expansion place env)
     `(let* (,@(mapcar #'list tmps vals)
	     (,(car new) ,getter))
	(setq ,(car new) (boole ,op ,(car new) ,bits))
	,setter)))

(defparameter *cua-path* #p"/dev/tty.PL2303-00001124")

(defun openraw (pathname &key (speed 57600) (ispeed speed) (ospeed speed) (bits 8) (parity nil))
  "Open serial device at PATHNAME"
  (declare (optimize (speed 0)))
  (let ((fd (sb-posix:open (namestring pathname)
			   (logior sb-posix:o-rdwr
				   sb-posix:o-excl
				   sb-posix:o-noctty
				   sb-posix:o-nonblock)
			   #o666)))
    (handler-case
      (let ((ts (sb-posix:tcgetattr fd)))
	(setf ts (sb-posix:cfmakeraw ts))
	(setf ts (sb-posix:cfsetospeed ospeed ts))
	(setf ts (sb-posix:cfsetispeed ispeed ts))
	(ecase bits
	  (5 (nboole boole-andc2 (sb-posix:termios-cflag ts) sb-posix:csize)
	     (nboole boole-ior (sb-posix:termios-cflag ts) sb-posix:cs5))
	  (6 (nboole boole-andc2 (sb-posix:termios-cflag ts) sb-posix:csize)
	     (nboole boole-ior (sb-posix:termios-cflag ts) sb-posix:cs6))
	  (7 (nboole boole-andc2 (sb-posix:termios-cflag ts) sb-posix:csize)
	     (nboole boole-ior (sb-posix:termios-cflag ts) sb-posix:cs7))
	  (8 (nboole boole-andc2 (sb-posix:termios-cflag ts) sb-posix:csize)
	     (nboole boole-ior (sb-posix:termios-cflag ts) sb-posix:cs8)))
	(ecase parity
	  ((nil)
	   (nboole boole-andc2 (sb-posix:termios-cflag ts) sb-posix:parenb)
	   (nboole boole-andc2 (sb-posix:termios-cflag ts) sb-posix:parodd))
	  (0
	   (nboole boole-ior   (sb-posix:termios-cflag ts) sb-posix:parenb)
	   (nboole boole-andc2 (sb-posix:termios-cflag ts) sb-posix:parodd))
	  (1
	   (nboole boole-ior   (sb-posix:termios-cflag ts) sb-posix:parenb)
	   (nboole boole-ior   (sb-posix:termios-cflag ts) sb-posix:parodd)))
	(nboole boole-ior (sb-posix:termios-cflag ts) sb-posix:cread)
	(nboole boole-ior (sb-posix:termios-cflag ts) sb-posix:clocal)
	(sb-posix:tcsetattr fd sb-posix:tcsanow ts)
	(sb-sys:make-fd-stream fd
			       :input t
			       :output t
			       :element-type :default
			       :buffering :line
			       :external-format :latin-1
			       :pathname pathname
			       :name pathname
			       :auto-close nil))
      (error (error)
	(sb-posix:close fd)
	(error error)))))

(defun mymakeraw (ts)
  "Random collections of supposedly useful termios flags"
  (declare (optimize (speed 0)))
  (setf ts (sb-posix:cfmakeraw ts))
  (nboole boole-andc2 (sb-posix:termios-iflag ts) (logior sb-posix:ignbrk
							     sb-posix:brkint
							     sb-posix:parmrk
							     sb-posix:istrip
							     sb-posix:inlcr
							     sb-posix:igncr
							     sb-posix:icrnl
							     sb-posix:ixon))
  (nboole boole-andc2 (sb-posix:termios-oflag ts) (logior sb-posix:opost))
  (nboole boole-andc2 (sb-posix:termios-lflag ts) (logior sb-posix:echo
							     sb-posix:echonl
							     sb-posix:icanon
							     sb-posix:isig
							     sb-posix:iexten))
  (nboole boole-andc2 (sb-posix:termios-cflag ts) (logior sb-posix:csize
							     sb-posix:parenb))
  (nboole boole-ior   (sb-posix:termios-cflag ts) (logior sb-posix:cs8
							     sb-posix:clocal
							     sb-posix:cread))
  (values ts))
