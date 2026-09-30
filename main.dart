

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Data Mahasiswa',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const DataMahasiswaPage(),
    );
  }
}

// ===== Model =====
class Mahasiswa {
  final String nim;
  final String nama;
  final String programStudi;
  final String kelas;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.programStudi,
    required this.kelas,
  });
}

// ===== Halaman Daftar Mahasiswa =====
class DataMahasiswaPage extends StatefulWidget {
  const DataMahasiswaPage({super.key});

  @override
  State<DataMahasiswaPage> createState() => _DataMahasiswaPageState();
}

class _DataMahasiswaPageState extends State<DataMahasiswaPage> {
  final List<Mahasiswa> _daftarMahasiswa = [
    const Mahasiswa(nim: '231001', nama: 'Andi Saputra', programStudi: 'Informatika', kelas: 'TI-3A'),
    const Mahasiswa(nim: '231002', nama: 'Budi Santoso', programStudi: 'Informatika', kelas: 'TI-3A'),
    const Mahasiswa(nim: '231003', nama: 'Citra Lestari', programStudi: 'Sistem Informasi', kelas: 'SI-3A'),
    const Mahasiswa(nim: '231004', nama: 'Dewi Anggraini', programStudi: 'Sistem Informasi', kelas: 'SI-3A'),
    const Mahasiswa(nim: '231005', nama: 'Eko Prasetyo', programStudi: 'Teknik Komputer', kelas: 'TK-3A'),
    const Mahasiswa(nim: '231006', nama: 'Fitri Handayani', programStudi: 'Informatika', kelas: 'TI-3B'),
    const Mahasiswa(nim: '231007', nama: 'Gilang Ramadhan', programStudi: 'Sistem Informasi', kelas: 'SI-3B'),
    const Mahasiswa(nim: '231008', nama: 'Hana Permata', programStudi: 'Teknik Komputer', kelas: 'TK-3A'),
    const Mahasiswa(nim: '231009', nama: 'Indra Wijaya', programStudi: 'Informatika', kelas: 'TI-3C'),
    const Mahasiswa(nim: '231010', nama: 'Julia Putri', programStudi: 'Teknik Komputer', kelas: 'TK-3B'),
  ];

  static const List<String> _pilihanProdi = [
    'Semua',
    'Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _kataKunci = '';
  String _filterProdi = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hasil gabungan filter program studi + pencarian nama/NIM
  List<Mahasiswa> get _hasilTampil {
    final q = _kataKunci.trim().toLowerCase();
    return _daftarMahasiswa.where((mhs) {
      final cocokProdi = _filterProdi == 'Semua' ||
          mhs.programStudi.trim().toLowerCase() == _filterProdi.toLowerCase();
      final cocokCari = q.isEmpty ||
          mhs.nama.toLowerCase().contains(q) ||
          mhs.nim.toLowerCase().contains(q);
      return cocokProdi && cocokCari;
    }).toList();
  }

  bool get _sedangMenyaring => _filterProdi != 'Semua' || _kataKunci.trim().isNotEmpty;

  Future<void> _bukaFormTambah() async {
    final Mahasiswa? mhsBaru = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(builder: (context) => const FormMahasiswaPage()),
    );

    if (mhsBaru != null) {
      setState(() {
        _daftarMahasiswa.add(mhsBaru);
      });
    }
  }

  void _bukaDetail(Mahasiswa mhs) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailMahasiswaPage(
          mahasiswa: mhs,
          onUpdate: (mhsBaru) {
            setState(() {
              final i = _daftarMahasiswa.indexOf(mhs);
              if (i != -1) _daftarMahasiswa[i] = mhsBaru;
            });
          },
          onDelete: () {
            setState(() {
              _daftarMahasiswa.remove(mhs);
            });
          },
        ),
      ),
    );
  }

  Widget _buildIsiDaftar(List<Mahasiswa> hasil) {
    // Empty state: seluruh data sudah dihapus
    if (_daftarMahasiswa.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              'Belum ada data mahasiswa',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }

    // Data ada, tetapi tidak cocok dengan pencarian/filter
    if (hasil.isEmpty) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return ListView.builder(
      itemCount: hasil.length,
      itemBuilder: (context, index) {
        final mhs = hasil[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(child: Text(mhs.nama[0].toUpperCase())),
            title: Text(mhs.nama),
            subtitle: Text('NIM: ${mhs.nim}\n${mhs.programStudi}\n${mhs.kelas}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _bukaDetail(mhs),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasilTampil;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Jumlah mahasiswa (berubah saat data ditambah/dihapus)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Text(
                  'Total Mahasiswa: ${_daftarMahasiswa.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_sedangMenyaring)
                  Text(
                    'Ditampilkan: ${hasil.length}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
              ],
            ),
          ),
          // Kolom pencarian
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _kataKunci = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIM...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _kataKunci.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _kataKunci = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          // Filter program studi
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: DropdownButtonFormField<String>(
              initialValue: _filterProdi,
              decoration: const InputDecoration(
                labelText: 'Filter Program Studi',
                prefixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(),
              ),
              items: _pilihanProdi
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _filterProdi = value;
                  });
                }
              },
            ),
          ),
          Expanded(child: _buildIsiDaftar(hasil)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormTambah,
        icon: const Icon(Icons.add),
        label: const Text('+ Tambah Mahasiswa'),
      ),
    );
  }
}

// ===== Halaman Detail Mahasiswa =====
class DetailMahasiswaPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final void Function(Mahasiswa) onUpdate;
  final VoidCallback onDelete;

  const DetailMahasiswaPage({
    super.key,
    required this.mahasiswa,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DetailMahasiswaPage> createState() => _DetailMahasiswaPageState();
}

class _DetailMahasiswaPageState extends State<DetailMahasiswaPage> {
  late Mahasiswa _mhs;

  @override
  void initState() {
    super.initState();
    _mhs = widget.mahasiswa;
  }

  Future<void> _bukaFormEdit() async {
    final Mahasiswa? hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (context) => FormMahasiswaPage(mahasiswa: _mhs),
      ),
    );

    if (hasil != null) {
      setState(() {
        _mhs = hasil;
      });
      widget.onUpdate(hasil);
    }
  }

  Future<void> _konfirmasiHapus() async {
    final bool? yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      widget.onDelete();
      if (mounted) {
        Navigator.pop(context); // kembali ke daftar
      }
    }
  }

  Widget _buildItem(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nilai,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItem('NIM', _mhs.nim),
            _buildItem('Nama', _mhs.nama),
            _buildItem('Program Studi', _mhs.programStudi),
            _buildItem('Kelas', _mhs.kelas),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _bukaFormEdit,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _konfirmasiHapus,
                icon: const Icon(Icons.delete),
                label: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Halaman Form (Tambah & Edit) =====
class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa; // null = mode tambah, berisi = mode edit

  const FormMahasiswaPage({super.key, this.mahasiswa});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _nimController;
  late final TextEditingController _prodiController;
  late final TextEditingController _kelasController;

  bool get _modeEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.mahasiswa?.nama ?? '');
    _nimController = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _prodiController = TextEditingController(text: widget.mahasiswa?.programStudi ?? '');
    _kelasController = TextEditingController(text: widget.mahasiswa?.kelas ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final mhs = Mahasiswa(
        nim: _nimController.text.trim(),
        nama: _namaController.text.trim(),
        programStudi: _prodiController.text.trim(),
        kelas: _kelasController.text.trim(),
      );
      Navigator.pop(context, mhs);
    }
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String pesanError,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return pesanError;
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Form Edit Mahasiswa' : 'Form Tambah Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_namaController, 'Nama', 'Nama wajib diisi'),
              _buildField(_nimController, 'NIM', 'NIM wajib diisi'),
              _buildField(_prodiController, 'Program Studi', 'Program Studi wajib diisi'),
              _buildField(_kelasController, 'Kelas', 'Kelas wajib diisi'),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
