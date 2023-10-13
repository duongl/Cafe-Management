using QuanLyQuanCafe.DAOO;
using QuanLyQuanCafe.DTOO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using QuanLyQuanCafe;
using System.Globalization;
using System.Threading;


namespace QuanLyQuanCafe
{
    

    public partial class FQuanlyTable : Form
    {
        int idSelect = -1;

        public FQuanlyTable()
        {
            InitializeComponent();

           

            LoadTable();
            LoadCategory();
            LoadComboboxTable(cbChuyenban);
        }
        #region Method

        void LoadCategory()
        {
            List<Category> listCategory = CategoryDAO.Instance.GetListCategory();
            comboBox1.DataSource = listCategory;
            comboBox1.DisplayMember = "Name";
            comboBox1.ValueMember = "ID";
        }

        void LoadFoodListByCategoryID(int id)
        {
            List<Food> listFood = FoodDAO.Instance.GetFoodCategoryID(id);
            comboBox2.DataSource = listFood; // loi
            comboBox2.DisplayMember = "Name";

            //List<Food> listFood = FoodDAO.Instance.GetFoodCategoryID(id);
            //if (listFood == null)
            //{
            //    listFood = new List<Food>();
            //}
            //comboBox2.DataSource = listFood;
            //comboBox2.DisplayMember = "Name";
        }
        void LoadTable()
        {
            List<Table> tableList = TableDAO.Instance.LoadTableList();

            foreach (Table Item in tableList)
            {
                Button btn = new Button() { Width = TableDAO.TableWeight, Height = TableDAO.TableHeight };
                btn.Text = Item.Name + Environment.NewLine + Item.Status;
                btn.Click += btn_Click;
                btn.Tag = Item;
                //switch (Item.Status)
                //{
                //    case "Trống":
                //        btn.BackColor = Color.Yellow;
                //        break;
                //    default:
                //        btn.BackColor = Color.Aquamarine;
                //        break;
                //}

                if (idSelect == Item.ID)
                {
                    btn.BackColor = Color.Aquamarine;
                }
                else
                {
                    if (Item.Status == "Trống")
                    {
                        btn.BackColor = Color.Yellow;
                    }
                    if (Item.Status == "Có Người")
                    {
                        btn.BackColor = Color.Red;
                    }
                   
                }

                flpTable.Controls.Add(btn);
            }
        }

        //private void btn_Click(object sender, EventArgs e)
        //{
        //    throw new NotImplementedException();
        //}
        void ShowBill(int id)
        {
            idSelect = id;

            flpTable.Controls.Clear();
            lsvBill.Items.Clear();
            List<QuanLyQuanCafe.DTOO.Menu> listBillInfo = MenuDAO.Instance.GetListMenuByTable(id);

            if (listBillInfo.Count() != 0)
            {
                BillDAO.TableDrinkUpdate(id, "Có Người");
            }

            float totalPrice = 0;
            foreach (QuanLyQuanCafe.DTOO.Menu item in listBillInfo)
            {
                ListViewItem lsvItem = new ListViewItem(item.FoodName.ToString());
                lsvItem.SubItems.Add(item.Count.ToString());
                lsvItem.SubItems.Add(item.Price.ToString());
                lsvItem.SubItems.Add(item.TotalPrice.ToString());
                totalPrice += item.TotalPrice;
                lsvBill.Items.Add(lsvItem);
            }
            CultureInfo culture = new CultureInfo("vi-VN");

            //Thread.CurrentThread.CurrentCulture = culture;

            txtTotalPrice.Text = totalPrice.ToString("c", culture);

        }

        void LoadComboboxTable(ComboBox cb)
        {
            cb.DataSource = TableDAO.Instance.LoadTableList();
            cb.DisplayMember = "Name";
            cb.ValueMember = "ID";
        }
        #endregion

        #region Events
        private void btn_Click(object sender, EventArgs e)
        {
            int tableID = ((sender as Button).Tag as Table).ID;
            lsvBill.Tag = (sender as Button).Tag;
            ShowBill(tableID);
            LoadTable();
        }
        private void FQuanlyTable_FormClosing(object sender, FormClosingEventArgs e)
        {

        }

        private void panel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void đăngXuấtToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void thôngTinCáNhânToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fQuanlyTaiKhoan f = new fQuanlyTaiKhoan();
            f.ShowDialog();
        }

        private void adminToolStripMenuItem_Click(object sender, EventArgs e)
        {
            fAdmin f = new fAdmin();
            f.ShowDialog();
        }
        //endregion


        private void lsvView_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = 0;
            ComboBox cb = sender as ComboBox;

            if (cb.SelectedItem == null)
                return;

            Category selected = cb.SelectedItem as Category;
            id = selected.ID;

            LoadFoodListByCategoryID(id);
        }

        private void btnThemmon_Click(object sender, EventArgs e)
        {
            
            //Table table = lsvBill.Tag as Table;

            if (idSelect != -1)
            {
                int id = idSelect;

                // int idBill = BillDAO.Instance.GetuncheckBillByTableID(table.ID);
                int idBill = BillDAO.Instance.GetuncheckBillByTableID(id);
                int foodID = (comboBox2.SelectedItem as Food).ID;
                int count = (int)numericUpDown1.Value;

                if (idBill == -1)
                {
                    //BillDAO.Instance.InsertBill(table.ID);
                    BillDAO.Instance.InsertBill(id);
                    BillInfoDAO.Instance.InsertBillInfo(BillDAO.Instance.GetMaxIDBill(), foodID, count);
                }
                else
                {
                    BillInfoDAO.Instance.InsertBillInfo(idBill, foodID, count);
                }

                // ShowBill(table.ID);
                ShowBill(id);

                LoadTable();
            }
           
        }

        private void btnCheckOut_Click(object sender, EventArgs e)
        {
            Table table = lsvBill.Tag as Table;

            int idBill = BillDAO.Instance.GetuncheckBillByTableID(table.ID);
            int discount = (int)numericUpDown2.Value;

            double totalPrice = Convert.ToDouble(txtTotalPrice.Text.Split(',')[0]);
            double finalTotalPrice = totalPrice - (totalPrice / 100) * discount;

            if (idBill != -1)
            {
                if (MessageBox.Show(string.Format("Bạn có chắc muốn thanh toán hóa đơn cho {0}\n Tổng tiền - (Tổng tiền / 100 ) x Giảm giá = {1} - ({1} / 100) x {2} = {3}", table.Name, totalPrice, discount, finalTotalPrice), "Thông Báo", MessageBoxButtons.OKCancel) == System.Windows.Forms.DialogResult.OK)
                {
                    BillDAO.Instance.CheckOut(idBill, discount);
                    ShowBill(table.ID);

                    LoadTable();
                }
            }
        }
        private void cbChuyenban_SelectedIndexChanged(object sender, EventArgs e)
        {

            if (idSelect != -1)
            {
                int idBanHienTai = idSelect;
                int idBanCanChuyen = (int)cbChuyenban.SelectedValue;
                BillDAO.ChuyenBill(idBanHienTai, idBanCanChuyen);
                BillDAO.XoaBill(idBanHienTai);
                LoadTable();
            }
         

            //int id1 = (lsvBill.Tag as Table).ID;

            //int id2 = (cbChuyenban.SelectedItem as Table).ID;
            //if (MessageBox.Show(string.Format("Bạn có thật sự muốn chuyển bàn {0} qua bàn {1}", (lsvBill.Tag as Table).Name, (cbChuyenban.SelectedItem as Table).Name), "Thông báo", MessageBoxButtons.OKCancel) == System.Windows.Forms.DialogResult.OK)
            //{
            //    TableDAO.Instance.SwitchTable(id1, id2);

            //    LoadTable();
            //}
        }
        #endregion
    }
}
