# Backend Dependency Gaps — Status Final

## Ditutup pass ini (patch `sekolah`, butuh review+deploy)

Directory, quiz-questions, reports, budget, letters, rupiah
controllers, dashboard fix, invoice paginate, plan/subs rupiah.
Detail + test: `API_GAP_REPORT.md`. Tanpa migrasi.

## BACKEND_GAP tersisa (terbukti tidak ada route)

- Siswa/staf/kelas/mapel CRUD (hanya import + directory read).
- Period PPDB designer, meridian CRUD lanjutan.
- Update/hapus tunggal minor (soal, buku — pola sama).
- Backup/license/email/webhook/maintenance API (sengaja web-only).

## Kompatibilitas

Perubahan rupiah bersifat additive-enforcement di controller API
saja; web tak tersentuh; route lama tak dihapus. Klien lama
(pra-rupiah) akan salah skala — didokumentasikan, reseed demo.
