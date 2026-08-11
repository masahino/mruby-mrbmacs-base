;; Line comment.
#| Multi-line comment.
   Semantic style preview. |#

(defparameter *project-name* "mrbmacs")
(defconstant +preview-count+ 17)

(defun greet (name &optional (count +preview-count+))
  "Return a formatted greeting."
  (let ((message (format nil "hello ~A (~D)" name count)))
    (if (> count 0)
        message
        "empty")))

(defclass preview ()
  ((name :initarg :name :accessor preview-name)))

(mapcar #'greet '("Ruby" "Python" "Lisp"))
