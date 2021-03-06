
(in-package :ulubis)

(def-wl-callback get-toplevel (client zxdg-surface (id :uint32))
  (let ((toplevel (make-zxdg-toplevel-v6 client 1 id :delete-fn (callback zxdg-toplevel-delete))))
    ;; Save the xdg-surface object so that configure events can be sent
    (setf (zxdg-surface-v6 toplevel) zxdg-surface)
    ;; Surface role now becomes xdg-toplevel
    (setf (role (wl-surface zxdg-surface)) toplevel)
    ;; Save the wl-surface associated with the toplevel
    (setf (wl-surface toplevel) (wl-surface zxdg-surface))
    ;; (current-view *compositor*) is now (active-surface (screen *compositor*))
    (push toplevel (surfaces (active-surface (screen *compositor*))))
    (with-wl-array array
      (zxdg-toplevel-v6-send-configure (->resource toplevel) 0 0 array)
      (zxdg-surface-v6-send-configure (->resource zxdg-surface) 0))))

(def-wl-callback get-popup (client zxdg-surface (id :uint32) (parent :pointer) (positioner :pointer))
  (let ((popup (make-zxdg-popup-v6 client 1 id :delete-fn (callback zxdg-popup-delete))))
    (setf (zxdg-surface-v6 popup) zxdg-surface)
    (setf (role (wl-surface zxdg-surface)) popup)
    (setf (wl-surface popup) (wl-surface zxdg-surface))
    (push popup (surfaces (active-surface (screen *compositor*))))
    (with-wl-array array
      (zxdg-popup-v6-send-configure (->resource popup) 0 0 1 1)
      (zxdg-surface-v6-send-configure (->resource zxdg-surface) 0))))

(defimplementation zxdg-surface-v6 (isurface)
  ((:get-toplevel get-toplevel)
   (:get-popup get-popup))
  ())
