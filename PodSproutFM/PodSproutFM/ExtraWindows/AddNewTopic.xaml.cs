using Microsoft.Win32;
using Oracle.ManagedDataAccess.Client;
using PodSproutFM.UserControls;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace PodSproutFM.ExtraWindows
{
    /// <summary>
    /// Логика взаимодействия для AddNewTopic.xaml
    /// </summary>
    public partial class AddNewTopic : Window
    {
        OracleConnection con = new OracleConnection();
        String connectionString = "DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA";
        byte[] image;
        string imageName;

        public event Action TopicAdded;

        public AddNewTopic()
        {
            InitializeComponent();
            con.ConnectionString = connectionString;
            TopicAdded += OnTopicAdded;
        }
        private void OnTopicAdded()
        {
            Application.Current.Dispatcher.Invoke(() =>
            {
                var homePage = Application.Current.Windows.OfType<Home>().FirstOrDefault();
                homePage?.LoadTopics();
            });
        }

        public void NarratorComboBox(OracleConnection con)
        {
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SYS.FILLNARRATORS";
            cmd.CommandType = CommandType.StoredProcedure;
            OracleParameter cursorParam = new OracleParameter("oPodcastCursor", OracleDbType.RefCursor);
            cursorParam.Direction = ParameterDirection.Output;
            cmd.Parameters.Add(cursorParam);
            cmd.ExecuteNonQuery();
            using (OracleDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    narratorNameCombo.Items.Add(reader.GetString(0));
                }
            }
        }

        private void TopicPreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex("[^0-9]+");
            e.Handled = regex.IsMatch(e.Text);
        }

        private void AddBtn_Click(object sender, RoutedEventArgs e)
        {
            string yearPattern = @"^(1989|199[0-9]|20[0-2][0-9]|202[0-4])$";
            Regex yearRegex = new Regex(yearPattern);
            if (String.IsNullOrWhiteSpace(topicName.Text.Trim()) ||
                String.IsNullOrWhiteSpace(narratorNameCombo.Text.Trim()) ||
                String.IsNullOrWhiteSpace(topicYear.Text.Trim()) ||
                String.IsNullOrWhiteSpace(imageName))
            {
                MessageBox.Show("Заполните все поля!");
                return;
            }
            if (!yearRegex.IsMatch(topicYear.Text.Trim()))
            {
                MessageBox.Show("Год должен быть в диапазоне от 1989 до текущего года!");
                return;
            }
            try
            {
                con.Open();
                OracleCommand cmd = con.CreateCommand();
                cmd.CommandText = "SYS.ADDTOPIC";
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("PNARRATORNAME", OracleDbType.Varchar2, 30).Value = narratorNameCombo.Text.Trim();
                cmd.Parameters.Add("PTOPICNAME", OracleDbType.Varchar2, 30).Value = topicName.Text.Trim();
                cmd.Parameters.Add("PTOPICRELEASED", OracleDbType.Int16, 10).Value = Convert.ToInt16(topicYear.Text.Trim());
                cmd.ExecuteNonQuery();
                con.Close();
                con.Open();
                FileStream fls;
                fls = new FileStream(imageName, FileMode.Open, FileAccess.Read);
                byte[] blob = new byte[fls.Length];
                fls.Read(blob, 0, System.Convert.ToInt32(fls.Length));
                fls.Close();
                if (!String.IsNullOrWhiteSpace(imageName))
                {
                    OracleCommand cmd2 = con.CreateCommand();
                    OracleTransaction txn;
                    txn = con.BeginTransaction(IsolationLevel.ReadCommitted);
                    cmd2.Transaction = txn;
                    cmd2.CommandText = "UPDATE SYS.topics_t SET topic_blob = :ImageFront WHERE UPPER(topic_name) = UPPER('" + topicName.Text.Trim() + "')";
                    cmd2.Parameters.Add(":ImageFront", OracleDbType.Blob);
                    cmd2.Parameters[":ImageFront"].Value = blob;
                    cmd2.ExecuteNonQuery();
                    txn.Commit();
                    con.Close();
                    con.Dispose();
                    TopicAdded?.Invoke();
                    MessageBox.Show("Тема успешно добавлена!");
                    this.Close();
                    Application.Current.Windows[0].Show();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при добавлении темы: {ex.Message}");
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void CloseBtn_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                using (OracleConnection con = new OracleConnection("DATA SOURCE=//localhost:1521/PodSproutPDB;PERSIST SECURITY INFO=True;USER ID=SYS;PASSWORD=jokimi;DBA PRIVILEGE=SYSDBA"))
                {
                    con.Open();

                    using (OracleCommand cmd = con.CreateCommand())
                    {
                        try
                        {
                            cmd.CommandText = "ALTER SESSION SET \"_ORACLE_SCRIPT\" = TRUE";
                            cmd.CommandType = CommandType.Text;
                            cmd.ExecuteNonQuery();
                        }
                        catch (OracleException ex)
                        {
                            if (ex.Number == 1031)
                            {
                                MessageBox.Show("Недостаточно прав для выполнения ALTER SESSION.");
                            }
                            else
                            {
                                MessageBox.Show($"Ошибка при выполнении ALTER SESSION: {ex.Message}");
                            }
                        }
                    }
                    NarratorComboBox(con);
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show($"Ошибка при подключении к базе данных: {ex.Message}");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Ошибка при загрузке окна: {ex.Message}");
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void AttachPhoto_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                OpenFileDialog openFileDialog = new OpenFileDialog()
                {
                    Filter = "Image Files|*.jpg;*.png;"
                };

                if (openFileDialog.ShowDialog() == true)
                {
                    imageName = openFileDialog.FileName;
                    image = File.ReadAllBytes(openFileDialog.FileName);
                    var bitmImg = new BitmapImage();
                    using (var mem = new MemoryStream(image))
                    {
                        mem.Position = 0;
                        bitmImg.BeginInit();
                        bitmImg.CacheOption = BitmapCacheOption.OnLoad;
                        bitmImg.StreamSource = mem;
                        bitmImg.EndInit();
                    }
                    bitmImg.Freeze();
                    coverImage.Source = bitmImg;
                }
                openFileDialog = null;
            }
            catch (System.ArgumentException ae)
            {
                imageName = "";
                MessageBox.Show(ae.Message.ToString());
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message.ToString());
            }
        }

        private void BtnClose_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
            Application.Current.Windows[0].Show();
        }

        private void BtnMinimize_Click(object sender, RoutedEventArgs e)
        {
            this.WindowState = WindowState.Minimized;
        }
    }
}