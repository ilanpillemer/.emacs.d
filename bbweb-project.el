;;; bbweb-project --- package to help with development of the bbweb project

;;; Commentary:

;; Settings and functions to support software development.

;;; Code:

(eval-and-compile
  (require 'projectile)
  (require 'eclimd))

(setq projectile-test-suffix-function (lambda (project-type) "" "Spec")
      projectile-find-dir-includes-top-level t
      eclimd-default-workspace (concat (locate-dominating-file default-directory ".dir-locals.el") ".."))

(setq-default indent-tabs-mode nil)
(puthash (projectile-project-root) "grunt karma:unit" projectile-test-cmd-map)

;;
;; override this function, from the projectile package, so that tests are created in the proper
;; location for this project
;;
(defun projectile-create-test-file-for (impl-file-path)
  "Create a test file for the file given by IMPL-FILE-PATH."
  (let* ((test-file (projectile--test-name-for-impl-name impl-file-path))
         (test-dir (replace-regexp-in-string "app/" "test/" (file-name-directory impl-file-path))))
    (unless (file-exists-p (expand-file-name test-file test-dir))
      (progn (unless (file-exists-p test-dir)
               (make-directory test-dir :create-parents))
             (concat test-dir test-file)))))

(defhydra hydra-nl-bbweb-project (:hint nil)
  "bbweb project build commands"
  ("t" (lambda () (interactive) (sbt-command "test:compile")) "sbt test:compile" :color blue)
  ("s" sbt-command "sbt command" :color blue)
  ("k" karma-start "karma unit test" :color blue)
  ("p" (lambda () (interactive) (helm-projectile-test-project (projectile-project-root))) "test project" :color blue))

;; this def uses a lambda to show that it is possible, id does not need to use it
(key-chord-define-global "c." '(lambda () (interactive)
                                 (hydra-nl-bbweb-project/body)))

;;
;;
(defun nl-karma-compile-filter ()
  "Filters unwanted lines from karma compile buffer."
  (interactive)
  (if (get-buffer "*karma start*")
      (progn
        (switch-to-buffer "*karma start*")
        (read-only-mode -1)
        (delete-matching-lines "\\bbweb\/(node_modules\\|target\\)" (point-min) (point-max))
        (read-only-mode 1))))

;;
;;
(defun nl-sbt-buffer-filter ()
  "Filters unwanted lines from karma compile buffer."
  (interactive)
  (if (get-buffer "*sbt*")
      (progn
        (switch-to-buffer "*sbt*")
        (read-only-mode -1)
        (delete-matching-lines "\\bbweb\/(node_modules\\|target\\)" (point-min) (point-max))
        (read-only-mode 1))))


(provide 'bbweb-project)
;;; bbweb-project.el ends here