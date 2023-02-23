use rand::prelude::Rng;
use rand::thread_rng;
use sphincsplus_rust::SphincsPlus;
use std::fs::create_dir;
use std::path::PathBuf;

static G_TEST_DATA_DIR: &str = "sphincs_plus_test_data";

fn get_hash_mode_name() -> String {
    #[cfg(feature = "haraka")]
    let hash_name = "haraka";
    #[cfg(feature = "sha2")]
    let hash_name = "sha2";
    #[cfg(feature = "shake")]
    let hash_name = "shake";

    #[cfg(feature = "hash_128")]
    let hash_size = "128";
    #[cfg(feature = "hash_192")]
    let hash_size = "192";
    #[cfg(feature = "hash_256")]
    let hash_size = "256";

    #[cfg(feature = "hash_options_f")]
    let hash_option = "f";
    #[cfg(feature = "hash_options_s")]
    let hash_option = "s";

    #[cfg(feature = "thashes_robust")]
    let thash = "robust";
    #[cfg(feature = "thashes_simple")]
    let thash = "simple";

    let ret = format!("{}-{}{}-{}", hash_name, hash_size, hash_option, thash);

    ret
}

fn buf_to_string(buf: &[u8]) -> String {
    let mut data = String::new();

    let one_line_count = 16;

    for i in 0..buf.len() {
        data += &format!("0x{:02x?}", buf[i]);
        if i + 1 != buf.len() {
            data += ", ";
            if i % one_line_count == one_line_count - 1 {
                data += "\n"
            }
        }
    }

    if buf.len() % one_line_count != 0 {
        data += "\n";
    }

    data
}

fn main() {
    if !PathBuf::from(G_TEST_DATA_DIR).exists() {
        create_dir(G_TEST_DATA_DIR).expect("can not create dir");
    }

    let mut data = String::new();

    let sp = SphincsPlus::new();

    let mut message = [0u8; 32];
    let mut rng = thread_rng();
    rng.fill(&mut message);

    let sign_data = sp.sign(&message);

    let ret = sp.verify(&sign_data);
    assert!(ret.is_ok());

    data += "// clang-format off\n";
    data += "#include <stddef.h>\n";
    data += "#include <stdint.h>\n\n";

    data += &format!(
        "uint8_t G_TEST_DATA_PUB_KEY[] = {{\n{}\n}};\n",
        buf_to_string(&sp.pk)
    );

    data += &format!(
        "uint8_t G_TEST_DATA_PRI_KEY[] = {{\n{}\n}};\n",
        buf_to_string(&sp.sk)
    );

    data += &format!(
        "uint8_t G_TEST_DATA_MSG[] = {{\n{}\n}};\n",
        buf_to_string(&message)
    );

    data += &format!(
        "uint8_t G_TEST_DATA_SIGN[] = {{\n{}\n}};\n",
        buf_to_string(&sign_data)
    );
    data += "// clang-format on\n";

    let file_path = PathBuf::from(G_TEST_DATA_DIR).join(get_hash_mode_name() + ".h");
    if file_path.exists() {
        std::fs::remove_file(&file_path).expect("TODO");
    }

    let ret = std::fs::write(&file_path, data);
    if ret.is_err() {
        panic!("write data failed : {}", ret.unwrap_err());
    }
}
