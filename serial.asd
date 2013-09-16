;;; -*- Lisp -*-
(defpackage :serial-asd (:use :cl :asdf))
(in-package :serial-asd)

(defsystem :serial
    :depends-on (:readg)
    :components ((:file "package")
		 (:file "serial" :depends-on ("package"))))
